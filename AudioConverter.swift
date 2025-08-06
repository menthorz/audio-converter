import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct AudioConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - Models

enum AudioFormat: String, CaseIterable {
    case mp3 = "mp3"
    case wav = "wav"
    case m4a = "m4a"
    case aac = "aac"
    case flac = "flac"
    
    var displayName: String {
        switch self {
        case .mp3: return "MP3"
        case .wav: return "WAV"
        case .m4a: return "M4A"
        case .aac: return "AAC"
        case .flac: return "FLAC"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
    
    var utType: UTType {
        switch self {
        case .mp3: return UTType.mp3
        case .wav: return UTType.wav
        case .m4a: return UTType.mpeg4Audio
        case .aac: return UTType.mpeg4Audio
        case .flac: return UTType("org.xiph.flac") ?? UTType.audio
        }
    }
}

enum ConversionQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case lossless = "lossless"
    
    var displayName: String {
        switch self {
        case .low: return "Baixa (128kbps)"
        case .medium: return "Média (192kbps)"
        case .high: return "Alta (320kbps)"
        case .lossless: return "Sem Perda"
        }
    }
    
    var bitrate: Int {
        switch self {
        case .low: return 128000
        case .medium: return 192000
        case .high: return 320000
        case .lossless: return 0
        }
    }
}

struct AudioFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    var outputFormat: AudioFormat = .mp3
    var quality: ConversionQuality = .high
    var status: ConversionStatus = .waiting
    var progress: Double = 0.0
    var outputURL: URL?
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.size = Int64((try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
    }
    
    var sizeString: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

enum ConversionStatus {
    case waiting
    case converting
    case completed
    case failed
    
    var displayName: String {
        switch self {
        case .waiting: return "Aguardando"
        case .converting: return "Convertendo"
        case .completed: return "Concluído"
        case .failed: return "Erro"
        }
    }
    
    var color: Color {
        switch self {
        case .waiting: return .secondary
        case .converting: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
}

// MARK: - Audio Converter Service

@MainActor
class AudioConverterService: ObservableObject {
    @Published var files: [AudioFile] = []
    @Published var isConverting = false
    @Published var outputDirectory: URL?
    
    private var conversionTasks: [UUID: Task<Void, Never>] = [:]
    
    init() {
        setupOutputDirectory()
    }
    
    private func setupOutputDirectory() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        outputDirectory = documentsPath?.appendingPathComponent("Audio Conversions")
        
        if let outputDirectory = outputDirectory {
            try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        }
    }
    
    func addFiles(_ urls: [URL]) {
        let audioExtensions = ["mp3", "wav", "m4a", "aac", "flac", "mp4", "mov", "avi"]
        
        for url in urls {
            let ext = url.pathExtension.lowercased()
            if audioExtensions.contains(ext) {
                let audioFile = AudioFile(url: url)
                if !files.contains(where: { $0.url == url }) {
                    files.append(audioFile)
                }
            }
        }
    }
    
    func removeFile(_ file: AudioFile) {
        conversionTasks[file.id]?.cancel()
        conversionTasks.removeValue(forKey: file.id)
        files.removeAll { $0.id == file.id }
    }
    
    func clearCompleted() {
        files.removeAll { $0.status == .completed }
    }
    
    func convertAll() {
        guard !isConverting else { return }
        isConverting = true
        
        let waitingFiles = files.filter { $0.status == .waiting }
        
        Task {
            for file in waitingFiles {
                await convertFile(file)
            }
            await MainActor.run {
                isConverting = false
            }
        }
    }
    
    func convertFile(_ file: AudioFile) async {
        guard let outputDirectory = outputDirectory else { return }
        
        let task = Task {
            await MainActor.run {
                if let index = files.firstIndex(where: { $0.id == file.id }) {
                    files[index].status = .converting
                    files[index].progress = 0.0
                }
            }
            
            let outputFileName = "\(file.url.deletingPathExtension().lastPathComponent).\(file.outputFormat.fileExtension)"
            let outputURL = outputDirectory.appendingPathComponent(outputFileName)
            
            do {
                try await performConversion(from: file.url, to: outputURL, format: file.outputFormat, quality: file.quality) { progress in
                    Task { @MainActor in
                        if let index = self.files.firstIndex(where: { $0.id == file.id }) {
                            self.files[index].progress = progress
                        }
                    }
                }
                
                await MainActor.run {
                    if let index = files.firstIndex(where: { $0.id == file.id }) {
                        files[index].status = .completed
                        files[index].progress = 1.0
                        files[index].outputURL = outputURL
                    }
                }
            } catch {
                await MainActor.run {
                    if let index = files.firstIndex(where: { $0.id == file.id }) {
                        files[index].status = .failed
                    }
                }
            }
        }
        
        conversionTasks[file.id] = task
        await task.value
        conversionTasks.removeValue(forKey: file.id)
    }
    
    private func performConversion(
        from inputURL: URL,
        to outputURL: URL,
        format: AudioFormat,
        quality: ConversionQuality,
        progressCallback: @escaping (Double) -> Void
    ) async throws {
        
        // Simular progresso para demonstração
        for i in 0...100 {
            try await Task.sleep(nanoseconds: 30_000_000) // 30ms
            progressCallback(Double(i) / 100.0)
        }
        
        // Por ora, apenas copia o arquivo para demonstração
        // Em uma implementação real, você usaria FFmpeg ou AVFoundation
        try FileManager.default.copyItem(at: inputURL, to: outputURL)
    }
    
    func setOutputDirectory(_ url: URL) {
        outputDirectory = url
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var converterService = AudioConverterService()
    @State private var showingDirectoryPicker = false
    @State private var showingCredits = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(converterService: converterService, showingDirectoryPicker: $showingDirectoryPicker, showingCredits: $showingCredits)
            Divider()
            
            if converterService.files.isEmpty {
                EmptyStateView(showingCredits: $showingCredits)
            } else {
                FileListView(converterService: converterService)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .fileImporter(
            isPresented: $showingDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                converterService.setOutputDirectory(url)
            }
        }
        .sheet(isPresented: $showingCredits) {
            CreditsView()
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers)
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var urls: [URL] = []
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                defer { group.leave() }
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
            }
        }
        
        group.notify(queue: .main) {
            converterService.addFiles(urls)
        }
        
        return true
    }
}

// MARK: - Credits View

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEasterEgg = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header com animação
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                                .scaleEffect(scale)
                                .rotationEffect(.degrees(rotationAngle))
                                .shadow(radius: 10)
                            
                            Text("🎵")
                                .font(.system(size: 50))
                                .scaleEffect(scale)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                scale = scale == 1.0 ? 1.2 : 1.0
                                rotationAngle += 360
                                sparkleOpacity = sparkleOpacity == 0 ? 1.0 : 0
                            }
                        }
                        
                        Text("Audio Converter")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        
                        Text("v1.0.0")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Desenvolvedor com estilo
                    VStack(spacing: 20) {
                        HStack {
                            Text("👨‍💻")
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Desenvolvido por")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Raphael")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                
                                Text("@menthorz")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        showingEasterEgg.toggle()
                                    }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .cornerRadius(15)
                        
                        if showingEasterEgg {
                            VStack(spacing: 10) {
                                Text("🚀 Easter Egg Descoberto! 🚀")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                
                                Text("Você encontrou o segredo do desenvolvedor!")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                
                                Text("\"Código é arte, e arte é paixão\" ✨")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    // Tecnologias usadas
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🛠️ Tecnologias")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            TechBadge(icon: "swift", name: "Swift", color: .orange)
                            TechBadge(icon: "paintbrush.fill", name: "SwiftUI", color: .blue)
                            TechBadge(icon: "waveform", name: "AVFoundation", color: .green)
                            TechBadge(icon: "doc.fill", name: "UniformTypeIdentifiers", color: .purple)
                        }
                    }
                    
                    // Agradecimentos com animação
                    VStack(spacing: 15) {
                        Text("🙏 Agradecimentos")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            Text("À comunidade Swift por tornar o desenvolvimento incrível")
                            Text("Aos usuários que tornam este app útil")
                            Text("E a você, por descobrir esta tela! 😄")
                        }
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    }
                    
                    // Sparkles animation overlay
                    if sparkleOpacity > 0 {
                        ForEach(0..<20, id: \.self) { _ in
                            Text("✨")
                                .font(.caption)
                                .opacity(sparkleOpacity)
                                .position(
                                    x: CGFloat.random(in: 50...300),
                                    y: CGFloat.random(in: 50...200)
                                )
                                .animation(.easeOut(duration: 2), value: sparkleOpacity)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .navigationTitle("Créditos")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Fechar") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct TechBadge: View {
    let icon: String
    let name: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct HeaderView: View {
    @ObservedObject var converterService: AudioConverterService
    @Binding var showingDirectoryPicker: Bool
    @Binding var showingCredits: Bool
    @State private var showingFilePicker = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("🎵 Audio Converter")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button("ℹ️") {
                        showingCredits = true
                    }
                    .buttonStyle(.plain)
                    .help("Créditos e informações sobre o app")
                }
                
                Text("Converta seus arquivos de áudio para diferentes formatos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Button("📁 Adicionar Arquivos") {
                        showingFilePicker = true
                    }
                    .controlSize(.large)
                    
                    Button("📂 Pasta de Saída") {
                        showingDirectoryPicker = true
                    }
                    .controlSize(.large)
                    
                    Button("🚀 Converter Todos") {
                        converterService.convertAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(converterService.files.isEmpty || converterService.isConverting)
                }
                
                if let outputDir = converterService.outputDirectory {
                    Text("📍 Saída: \(outputDir.lastPathComponent)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.audio, .movie],
            allowsMultipleSelection: true
        ) { result in
            if case .success(let urls) = result {
                converterService.addFiles(urls)
            }
        }
    }
}

struct EmptyStateView: View {
    @Binding var showingCredits: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Nenhum arquivo de áudio")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Arraste arquivos aqui ou clique em 'Adicionar Arquivos'")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("Formatos suportados:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("🎵 MP3 • 🎼 WAV • 🎹 FLAC • 🎸 M4A • 🎤 AAC")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Botão discreto para créditos
            Button("Desenvolvido por @menthorz 👨‍💻") {
                showingCredits = true
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            .font(.caption)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FileListView: View {
    @ObservedObject var converterService: AudioConverterService
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("📋 \(converterService.files.count) arquivo(s)")
                    .font(.headline)
                
                Spacer()
                
                Button("🧹 Limpar Concluídos") {
                    converterService.clearCompleted()
                }
                .disabled(!converterService.files.contains { $0.status == .completed })
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(converterService.files) { file in
                        FileRowView(file: file, converterService: converterService)
                    }
                }
                .padding()
            }
        }
    }
}

struct FileRowView: View {
    let file: AudioFile
    @ObservedObject var converterService: AudioConverterService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.blue)
                    Text(file.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                
                HStack {
                    Text("📦 \(file.sizeString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(file.status.color)
                            .frame(width: 6, height: 6)
                        Text(file.status.displayName)
                            .font(.caption)
                            .foregroundColor(file.status.color)
                    }
                }
            }
            
            Spacer()
            
            if file.status == .waiting {
                VStack(alignment: .trailing, spacing: 4) {
                    Picker("🎯 Formato", selection: bindingForFormat(file)) {
                        ForEach(AudioFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    
                    Picker("⚡ Qualidade", selection: bindingForQuality(file)) {
                        ForEach(ConversionQuality.allCases, id: \.self) { quality in
                            Text(quality.displayName).tag(quality)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 140)
                }
            }
            
            if file.status == .converting {
                VStack(alignment: .trailing, spacing: 4) {
                    ProgressView(value: file.progress)
                        .frame(width: 100)
                    
                    Text("\(Int(file.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            } else if file.status == .completed {
                Button("👁️ Mostrar no Finder") {
                    if let outputURL = file.outputURL {
                        NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: "")
                    }
                }
                .controlSize(.small)
            }
            
            Button {
                converterService.removeFile(file)
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .controlSize(.small)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func bindingForFormat(_ file: AudioFile) -> Binding<AudioFormat> {
        Binding(
            get: { file.outputFormat },
            set: { newFormat in
                if let index = converterService.files.firstIndex(where: { $0.id == file.id }) {
                    converterService.files[index].outputFormat = newFormat
                }
            }
        )
    }
    
    private func bindingForQuality(_ file: AudioFile) -> Binding<ConversionQuality> {
        Binding(
            get: { file.quality },
            set: { newQuality in
                if let index = converterService.files.firstIndex(where: { $0.id == file.id }) {
                    converterService.files[index].quality = newQuality
                }
            }
        )
    }
}

// Main entry point
AudioConverterApp.main()
