# 🎵 Audio Converter

<div align="center">

![Audio Converter Icon](https://img.shields.io/badge/Audio-Converter-blue?style=for-the-badge&logo=music)
![Platform](https://img.shields.io/badge/Platform-macOS%2013.0+-green?style=for-the-badge&logo=apple)
![Architecture](https://img.shields.io/badge/Architecture-Universal%20Binary-orange?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9+-red?style=for-the-badge&logo=swift)

**Um conversor de áudio moderno e intuitivo para macOS**

[Download Latest Release](https://github.com/menthorz/audio-converter/releases/latest) • [Report Bug](https://github.com/menthorz/audio-converter/issues) • [Request Feature](https://github.com/menthorz/audio-converter/issues)

</div>

## ✨ Características

### 🎯 Interface Moderna
- **SwiftUI Nativa**: Interface fluida e responsiva desenvolvida com SwiftUI
- **Drag & Drop**: Arraste arquivos diretamente para a aplicação
- **Design Intuitivo**: Interface limpa e fácil de usar
- **Feedback Visual**: Progresso em tempo real durante conversões

### 🔄 Conversão Poderosa
- **Múltiplos Formatos**: Suporte para MP3, WAV, M4A, FLAC e mais
- **Qualidade Personalizável**: Escolha entre diferentes níveis de qualidade
- **Processamento Rápido**: Conversão otimizada usando AVFoundation
- **Batch Processing**: Converta múltiplos arquivos simultaneamente

### 🚀 Performance
- **Binário Universal**: Execução nativa em Intel e Apple Silicon
- **Otimizado**: Performance máxima em ambas as arquiteturas
- **Baixo Uso de Recursos**: Processamento eficiente sem sobrecarregar o sistema

### 🎨 Experiência do Usuário
- **Créditos Interativos**: Sistema de créditos com animações e easter eggs
- **Notificações**: Feedback claro sobre o status das conversões
- **Suporte a Ícones Personalizados**: Interface visual atraente

## 📋 Requisitos do Sistema

- **macOS**: 13.0 (Ventura) ou superior
- **Arquitetura**: Intel (x86_64) ou Apple Silicon (ARM64)
- **Espaço**: ~5MB de espaço livre

## 🚀 Instalação

### Download Direto
1. Acesse a [página de releases](https://github.com/menthorz/audio-converter/releases/latest)
2. Baixe o arquivo `Audio-Converter-v1.1.0.zip`
3. Extraia o arquivo e mova `Audio Converter.app` para a pasta Applications
4. Execute o app

### Compilação Manual

```bash
# Clone o repositório
git clone https://github.com/menthorz/audio-converter.git
cd audio-converter

## 🎵 Como Usar

### Conversão Simples
1. **Abra** o Audio Converter
2. **Arraste** um arquivo de áudio para a janela
3. **Selecione** o formato de saída desejado
4. **Escolha** a qualidade (se aplicável)
5. **Clique** em "Converter"

### Formatos Suportados

| Formato | Extensão | Qualidade | Notas |
|---------|----------|-----------|-------|
| MP3     | `.mp3`   | 128-320kbps | Universal |
| WAV     | `.wav`   | Lossless | Alta qualidade |
| M4A     | `.m4a`   | 128-256kbps | Apple padrão |
| FLAC    | `.flac`  | Lossless | Compressão sem perda |

## 🛠 Desenvolvimento

### Tecnologias Utilizadas
- **Swift 5.9+**: Linguagem principal
- **SwiftUI**: Framework de interface
- **AVFoundation**: Processamento de áudio
- **UniformTypeIdentifiers**: Suporte a tipos de arquivo

### Estrutura do Projeto
```
AudioConverter/
├── AudioConverter.swift    # Aplicação principal
├── build.sh               # Script de build universal
├── AudioConverter.icns    # Ícone da aplicação
├── README.md             # Este arquivo
└── Audio Converter.app/  # App bundle gerado
```

### Script de Build
O projeto inclui um script de build avançado que:
- Compila para ARM64 e x86_64 separadamente
- Cria binário universal usando `lipo`
- Gera app bundle completo com recursos
- Inclui fallback para compilação nativa

## 🎨 Recursos Visuais

### Screenshots
*Em breve: capturas de tela da interface*

### Ícone Personalizado
O app inclui um ícone customizado otimizado para diferentes resoluções (16px a 1024px).

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Tipos de Contribuição
- 🐛 Correção de bugs
- ✨ Novas funcionalidades
- 📚 Melhorias na documentação
- � Melhorias na interface
- 🔧 Otimizações de performance

## 📝 Changelog

### v1.1.0 (2025-08-06)
- ✨ Implementado sistema de créditos com animações
- � Adicionado ícone personalizado
- 🚀 Binário universal (ARM64 + x86_64)
- � Melhorias na interface SwiftUI
- � Suporte completo para Apple Silicon

### v1.0.0 (2025-08-06)
- 🎉 Release inicial
- 🎵 Conversão básica de formatos de áudio
- 🖱️ Interface drag & drop
- ⚡ Processamento usando AVFoundation

## 🏆 Créditos

**Desenvolvido por**: [Raphael (@menthorz)](https://github.com/menthorz)

### Agradecimentos
- Apple por SwiftUI e AVFoundation
- Comunidade Swift por ferramentas e recursos
- Usuários que testaram e forneceram feedback

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## � Links Úteis

- [Documentação Swift](https://docs.swift.org/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [AVFoundation Guide](https://developer.apple.com/documentation/avfoundation)
- [macOS App Distribution](https://developer.apple.com/macos/distribution/)

---

<div align="center">

**Feito com ❤️ e Swift**

[⭐ Star no GitHub](https://github.com/menthorz/audio-converter) • [🐛 Report Issues](https://github.com/menthorz/audio-converter/issues) • [💬 Discussions](https://github.com/menthorz/audio-converter/discussions)

</div>

Este projeto é fornecido como está, para fins educacionais e de demonstração.

## 🙏 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir funcionalidades
- Enviar pull requests
- Melhorar a documentação

---

**Desenvolvido com ❤️ usando Swift e SwiftUI**

*Para uma implementação completa de conversão, considere integrar com FFmpeg ou usar AVFoundation para conversões reais entre formatos.*
