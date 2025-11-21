#!/bin/bash
#
# install.sh - Instalador do Linux Home Cleanup Toolkit
# Autor: Johnny (@johnnyvaz)
# Data: 2025-11-21
#
# Instala os scripts de limpeza no sistema do usuário
#

set -euo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuração
INSTALL_DIR="$HOME/.local/bin"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${BLUE}"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║       Linux Home Cleanup Toolkit - Instalador             ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar se está no diretório correto
if [ ! -f "$REPO_DIR/analise-espaco.sh" ]; then
    echo -e "${RED}Erro: Execute este script do diretório do repositório${NC}"
    exit 1
fi

# Criar diretório de instalação se não existir
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Criando diretório $INSTALL_DIR...${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Verificar se ~/.local/bin está no PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}Adicionando ~/.local/bin ao PATH...${NC}"

    # Detectar shell
    if [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        echo -e "${GREEN}Adicionado ao ~/.zshrc${NC}"
    fi

    if [ -f "$HOME/.bashrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo -e "${GREEN}Adicionado ao ~/.bashrc${NC}"
    fi

    echo -e "${YELLOW}Reinicie o terminal ou execute: source ~/.bashrc${NC}"
fi

# Instalar scripts
echo -e "\n${CYAN}Instalando scripts...${NC}\n"

# Lista de scripts para instalar
declare -A SCRIPTS=(
    ["analise-espaco.sh"]="analise-espaco"
    ["limpeza-geral.sh"]="limpeza-geral"
    ["limpeza-profunda.sh"]="limpeza-profunda"
    ["scripts/analise-ia.sh"]="analise-ia"
)

for script in "${!SCRIPTS[@]}"; do
    dest="${SCRIPTS[$script]}"
    src="$REPO_DIR/$script"

    if [ -f "$src" ]; then
        cp "$src" "$INSTALL_DIR/$dest"
        chmod +x "$INSTALL_DIR/$dest"
        echo -e "  ${GREEN}✓${NC} $dest"
    else
        echo -e "  ${RED}✗${NC} $script não encontrado"
    fi
done

# Criar diretório para relatórios
REPORTS_DIR="$HOME/Documentos/limpeza/reports"
if [ ! -d "$REPORTS_DIR" ]; then
    mkdir -p "$REPORTS_DIR"
    echo -e "\n${GREEN}Diretório de relatórios criado: $REPORTS_DIR${NC}"
fi

# Resumo
echo -e "\n${BOLD}${GREEN}Instalação concluída!${NC}\n"
echo -e "Comandos disponíveis:"
echo -e "  ${CYAN}analise-espaco${NC}    - Análise de espaço em disco"
echo -e "  ${CYAN}limpeza-geral${NC}     - Limpeza interativa"
echo -e "  ${CYAN}limpeza-profunda${NC}  - Limpeza avançada"
echo -e "  ${CYAN}analise-ia${NC}        - Gerar relatório para IA"
echo ""
echo -e "${YELLOW}Dica: Execute 'analise-espaco' para começar!${NC}"
