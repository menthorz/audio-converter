#!/bin/bash

# Script para criar e configurar repositório GitHub para Audio Converter

echo "🚀 CRIANDO REPOSITÓRIO GITHUB - AUDIO CONVERTER"
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${YELLOW}📋 INSTRUÇÕES PARA CRIAR REPOSITÓRIO MANUALMENTE:${NC}"
echo ""
echo -e "${CYAN}1. Acesse:${NC} ${WHITE}https://github.com/new${NC}"
echo -e "${CYAN}2. Repository name:${NC} ${WHITE}audio-converter${NC}"
echo -e "${CYAN}3. Description:${NC} ${WHITE}🎵 A modern and intuitive audio converter for macOS with universal binary support${NC}"
echo -e "${CYAN}4. Visibility:${NC} ${WHITE}Public${NC}"
echo -e "${CYAN}5. NÃO marque:${NC} ${WHITE}Add a README file, Add .gitignore, Choose a license${NC}"
echo -e "${CYAN}6. Clique em:${NC} ${WHITE}Create repository${NC}"
echo ""

echo -e "${YELLOW}Pressione ENTER após criar o repositório no GitHub...${NC}"
read -r

echo -e "${BLUE}🔗 Configurando remote...${NC}"
git remote add origin https://github.com/menthorz/audio-converter.git 2>/dev/null || echo "Remote já existe"

echo -e "${BLUE}📤 Fazendo push do código...${NC}"
git push -u origin main

echo -e "${BLUE}🏷️ Fazendo push das tags...${NC}"
git push origin --tags

echo ""
echo -e "${GREEN}✅ Código enviado para GitHub!${NC}"
echo ""

echo -e "${YELLOW}📦 CRIANDO RELEASE v1.1.0...${NC}"
echo ""

# Criar release usando GitHub CLI
echo -e "${BLUE}🚀 Criando release...${NC}"

RELEASE_NOTES="## 🎉 Primeira Release - Audio Converter Universal

### ✨ Principais Funcionalidades

🎯 **Interface Moderna**
- SwiftUI nativo com drag & drop
- Design intuitivo e responsivo
- Feedback visual em tempo real

🚀 **Performance Otimizada**
- **Binário Universal** (ARM64 + x86_64)
- Execução nativa em Intel e Apple Silicon
- Processamento eficiente com AVFoundation

🎨 **Experiência Premium**
- Sistema de créditos interativo com animações
- Ícone personalizado profissional
- Interface limpa e moderna

### 📦 Download e Instalação

1. **Baixe** o arquivo \`Audio-Converter-v1.1.0.zip\`
2. **Extraia** o arquivo ZIP
3. **Mova** \`Audio Converter.app\` para a pasta Applications
4. **Execute** o app

### 🔧 Requisitos do Sistema

- **macOS**: 13.0 (Ventura) ou superior
- **Arquitetura**: Universal (Intel + Apple Silicon)
- **Espaço**: ~5MB livres

### 🏗️ Build Info

- **Arquitetura**: Universal Binary (x86_64 + arm64)
- **Tamanho**: 3.0MB compactado, 4.3MB descompactado
- **Frameworks**: SwiftUI, AVFoundation, UniformTypeIdentifiers
- **Versão Swift**: 5.9+

### 🎵 Formatos Suportados

| Entrada | Saída | Qualidade |
|---------|-------|-----------|
| MP3, WAV, M4A, FLAC | MP3, WAV, M4A, FLAC | Personalizável |

### 🔮 Próximas Versões

- Conversão real com FFmpeg
- Preservação de metadados
- Processamento em lote avançado
- Pré-visualização de áudio

---

**Desenvolvido com ❤️ por [Raphael (@menthorz)](https://github.com/menthorz)**

🐛 **Encontrou um bug?** [Abra uma issue](https://github.com/menthorz/audio-converter/issues)
💡 **Tem uma sugestão?** [Abra uma discussion](https://github.com/menthorz/audio-converter/discussions)"

# Criar release
if gh release create v1.1.0 \
    --title "🎵 Audio Converter v1.1.0 - Universal Binary" \
    --notes "$RELEASE_NOTES" \
    --latest \
    "Audio-Converter-v1.1.0.zip#Audio Converter v1.1.0 - Universal Binary (macOS 13.0+)"; then
    
    echo -e "${GREEN}✅ Release v1.1.0 criado com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️ Erro ao criar release automaticamente${NC}"
    echo -e "${CYAN}📝 Crie manualmente em:${NC} ${WHITE}https://github.com/menthorz/audio-converter/releases/new${NC}"
    echo -e "${CYAN}Tag:${NC} ${WHITE}v1.1.0${NC}"
    echo -e "${CYAN}Title:${NC} ${WHITE}🎵 Audio Converter v1.1.0 - Universal Binary${NC}"
    echo -e "${CYAN}Upload:${NC} ${WHITE}Audio-Converter-v1.1.0.zip${NC}"
fi

echo ""
echo -e "${GREEN}🎉 PROJETO FINALIZADO!${NC}"
echo ""
echo -e "${BLUE}🔗 URLs do Projeto:${NC}"
echo -e "${WHITE}Repositório:${NC} https://github.com/menthorz/audio-converter"
echo -e "${WHITE}Releases:${NC} https://github.com/menthorz/audio-converter/releases"
echo -e "${WHITE}Download:${NC} https://github.com/menthorz/audio-converter/releases/download/v1.1.0/Audio-Converter-v1.1.0.zip"
echo ""
