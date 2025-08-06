#!/bin/bash

# Build script para Audio Converter

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ${WHITE}AUDIO CONVERTER - BUILD SCRIPT${BLUE}               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

APP_NAME="Audio Converter.app"
APP_DIR="$APP_NAME/Contents"

echo -e "${CYAN}🔨 Compilando aplicação Swift para múltiplas arquiteturas...${NC}"

# Verificar arquiteturas disponíveis
echo -e "${CYAN}🔍 Detectando arquiteturas disponíveis...${NC}"

# Compilar para ARM64 (Apple Silicon)
echo -e "${BLUE}📱 Compilando para ARM64 (Apple Silicon)...${NC}"
if swiftc -target arm64-apple-macos13.0 -o "AudioConverter-arm64" AudioConverter.swift -framework SwiftUI -framework AVFoundation -framework UniformTypeIdentifiers; then
    echo -e "${GREEN}✅ ARM64 compilado com sucesso!${NC}"
    ARM64_BINARY="AudioConverter-arm64"
else
    echo -e "${YELLOW}⚠️ Falha na compilação ARM64 (normal em alguns ambientes)${NC}"
    ARM64_BINARY=""
fi

# Compilar para x86_64 (Intel)
echo -e "${BLUE}💻 Compilando para x86_64 (Intel)...${NC}"
if swiftc -target x86_64-apple-macos13.0 -o "AudioConverter-x86_64" AudioConverter.swift -framework SwiftUI -framework AVFoundation -framework UniformTypeIdentifiers; then
    echo -e "${GREEN}✅ x86_64 compilado com sucesso!${NC}"
    X86_BINARY="AudioConverter-x86_64"
else
    echo -e "${YELLOW}⚠️ Falha na compilação x86_64 (normal em alguns ambientes)${NC}"
    X86_BINARY=""
fi

# Fallback para compilação padrão se as específicas falharem
if [[ -z "$ARM64_BINARY" && -z "$X86_BINARY" ]]; then
    echo -e "${YELLOW}⚠️ Compilações específicas falharam, usando compilação padrão...${NC}"
    if swiftc -o "AudioConverter" AudioConverter.swift -framework SwiftUI -framework AVFoundation -framework UniformTypeIdentifiers; then
        echo -e "${GREEN}✅ Compilação padrão bem-sucedida!${NC}"
        FINAL_BINARY="AudioConverter"
        ARCH_INFO="Arquitetura nativa"
    else
        echo -e "${RED}❌ Erro na compilação!${NC}"
        exit 1
    fi
elif [[ -n "$ARM64_BINARY" && -n "$X86_BINARY" ]]; then
    # Criar binário universal
    echo -e "${CYAN}🔀 Criando binário universal (ARM64 + x86_64)...${NC}"
    if lipo -create -output "AudioConverter" "$ARM64_BINARY" "$X86_BINARY"; then
        echo -e "${GREEN}✅ Binário universal criado!${NC}"
        FINAL_BINARY="AudioConverter"
        ARCH_INFO="Universal (ARM64 + x86_64)"
        # Limpar binários temporários
        rm -f "$ARM64_BINARY" "$X86_BINARY"
    else
        echo -e "${RED}❌ Erro ao criar binário universal!${NC}"
        exit 1
    fi
elif [[ -n "$ARM64_BINARY" ]]; then
    mv "$ARM64_BINARY" "AudioConverter"
    FINAL_BINARY="AudioConverter"
    ARCH_INFO="ARM64 (Apple Silicon)"
elif [[ -n "$X86_BINARY" ]]; then
    mv "$X86_BINARY" "AudioConverter"
    FINAL_BINARY="AudioConverter"
    ARCH_INFO="x86_64 (Intel)"
else
    echo -e "${RED}❌ Nenhum executável encontrado!${NC}"
    exit 1
fi

# Verificar arquiteturas do binário final
echo -e "${CYAN}🔍 Verificando arquiteturas do binário final...${NC}"
file "$FINAL_BINARY"

echo -e "${CYAN}📦 Criando bundle da aplicação...${NC}"

# Criar estrutura do app bundle
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

# Mover executável
mv "$FINAL_BINARY" "$APP_DIR/MacOS/"
echo -e "${GREEN}✅ Executável movido ($ARCH_INFO)${NC}"

# Copiar ícone se existir
if [[ -f "AudioConverter.icns" ]]; then
    cp "AudioConverter.icns" "$APP_DIR/Resources/"
    echo -e "${GREEN}✅ Ícone personalizado incluído${NC}"
fi

echo -e "${CYAN}📝 Criando Info.plist...${NC}"

# Criar Info.plist
cat > "$APP_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AudioConverter</string>
    <key>CFBundleIdentifier</key>
    <string>com.audioconverter.app</string>
    <key>CFBundleName</key>
    <string>Audio Converter</string>
    <key>CFBundleDisplayName</key>
    <string>Audio Converter</string>
    <key>CFBundleVersion</key>
    <string>1.1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AudioConverter</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>UTExportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeIdentifier</key>
            <string>public.audio</string>
            <key>UTTypeDescription</key>
            <string>Audio File</string>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.data</string>
            </array>
        </dict>
    </array>
    <key>NSAppleEventsUsageDescription</key>
    <string>Este app precisa acessar arquivos para conversão de áudio.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Audio Files</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.audio</string>
                <string>public.mp3</string>
                <string>com.microsoft.waveform-audio</string>
                <string>public.mpeg-4-audio</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

echo -e "${GREEN}✅ Info.plist criado${NC}"

# Calcular tamanho
app_size=$(du -sh "$APP_NAME" | cut -f1)
executable_size=$(du -sh "$APP_DIR/MacOS/AudioConverter" | cut -f1)

echo ""
echo -e "${GREEN}🎉 App bundle criado com sucesso!${NC}"
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    ${WHITE}RESUMO DO BUILD${BLUE}                         ║${NC}"
echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC} ${CYAN}App Bundle:${NC} $APP_NAME"
echo -e "${BLUE}║${NC} ${CYAN}Tamanho Total:${NC} $app_size"
echo -e "${BLUE}║${NC} ${CYAN}Executável:${NC} $executable_size"
echo -e "${BLUE}║${NC} ${CYAN}Arquitetura:${NC} $ARCH_INFO"
echo -e "${BLUE}║${NC} ${CYAN}Plataforma:${NC} macOS 13.0+"
echo -e "${BLUE}║${NC}"
echo -e "${BLUE}║${NC} ${WHITE}Funcionalidades incluídas:${NC}"
echo -e "${BLUE}║${NC}   • Interface SwiftUI moderna"
echo -e "${BLUE}║${NC}   • Drag & Drop de arquivos"
echo -e "${BLUE}║${NC}   • Conversão entre formatos"
echo -e "${BLUE}║${NC}   • Progresso em tempo real"
echo -e "${BLUE}║${NC}   • Seleção de qualidade"
echo -e "${BLUE}║${NC}   • Múltiplos formatos suportados"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}🚀 Para testar o app:${NC}"
echo -e "${WHITE}open '$APP_NAME'${NC}"
echo ""

# Perguntar se quer executar
echo -e "${YELLOW}Deseja executar o app agora? (s/n):${NC} \c"
read -r run_app

if [[ "$run_app" =~ ^[SsYy]$ ]]; then
    echo -e "${CYAN}Executando app...${NC}"
    open "$APP_NAME"
fi

echo ""
echo -e "${GREEN}✅ Build concluído!${NC}"
