#!/bin/bash
#
# limpeza-geral.sh - Script unificado de limpeza do sistema
# Autor: Johnny
# Atualizado: 2025-11-21
#
# Funcionalidades:
# - Limpeza de cache dos IDEs baseados em VS Code (Code, Cursor, Windsurf, Antigravity)
# - Limpeza de cache Python, Java/Gradle, Node.js
# - Limpeza do sistema (apt, journalctl)
# - Limpeza Docker
# - Análise de extensões antigas dos IDEs
#

set -euo pipefail

# ===== Cores para output =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ===== Funções Auxiliares =====
prompt_confirmation() {
    local prompt="$1"
    local response
    read -p "$prompt (s/n) " -n 1 -r response
    echo
    [[ $response =~ ^[Ss]$ ]]
}

format_size() {
    numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "${1}B"
}

get_dir_size() {
    if [ -d "$1" ]; then
        du -sb "$1" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

clean_directory() {
    local dir="$1"
    local desc="$2"

    if [ -d "$dir" ]; then
        local size
        size=$(get_dir_size "$dir")
        local size_human
        size_human=$(format_size "$size")
        echo -e "  ${YELLOW}Limpando${NC} $desc: ${CYAN}$size_human${NC}"
        rm -rf "${dir:?}/"* 2>/dev/null || true
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
    fi
}

# ===== Análise de Extensões =====
analyze_extensions() {
    local ext_dir="$1"
    local ide_name="$2"

    if [ ! -d "$ext_dir" ]; then
        return
    fi

    echo -e "${GREEN}>>> $ide_name - Extensoes${NC}"
    echo -e "${YELLOW}Extensoes ordenadas por tamanho (maiores primeiro):${NC}"
    echo ""

    while IFS= read -r line; do
        size=$(echo "$line" | awk '{print $1}')
        ext_path=$(echo "$line" | awk '{print $2}')
        ext_name=$(basename "$ext_path")

        if [ -d "$ext_path" ]; then
            local mod_date
            mod_date=$(stat -c '%y' "$ext_path" 2>/dev/null | cut -d' ' -f1)
            local now
            now=$(date +%s)
            local mod_epoch
            mod_epoch=$(stat -c '%Y' "$ext_path" 2>/dev/null || printf '%s\n' "$now")
            local mod_days
            mod_days=$(((now - mod_epoch) / 86400))

            if [ "$mod_days" -gt 180 ]; then
                echo -e "  ${RED}[ANTIGA]${NC} ${size}\t${mod_date} (${mod_days} dias)\t${ext_name}"
            elif [ "$mod_days" -gt 90 ]; then
                echo -e "  ${YELLOW}[90+ dias]${NC} ${size}\t${mod_date} (${mod_days} dias)\t${ext_name}"
            else
                echo -e "  ${NC}${size}\t${mod_date} (${mod_days} dias)\t${ext_name}"
            fi
        fi
    done < <(du -sh "$ext_dir"/*/ 2>/dev/null | sort -rh | head -20)

    echo ""

    echo -e "${YELLOW}Verificando versoes duplicadas...${NC}"
    find "$ext_dir" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | while IFS= read -r ext; do
        base_name=$(echo "$ext" | sed 's/-[0-9]*\.[0-9]*\.[0-9]*$//' | sed 's/-[0-9]*\.[0-9]*$//')
        echo "$base_name"
    done | sort | uniq -d | while IFS= read -r dup; do
        if [ -n "$dup" ]; then
            echo -e "${RED}  Duplicada: $dup${NC}"
            find "$ext_dir" -maxdepth 1 -mindepth 1 -type d -name "${dup}*" -print 2>/dev/null | while IFS= read -r ver; do
                size=$(du -sh "$ver" 2>/dev/null | cut -f1)
                echo -e "    - $(basename "$ver") (${size})"
            done
        fi
    done
    echo ""
}

# ===== MENU PRINCIPAL =====
show_menu() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Script de Limpeza Geral do Sistema  ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "1) Limpeza completa (todas as opções)"
    echo "2) Limpeza IDEs VS Code (Code, Cursor, Windsurf, Antigravity)"
    echo "3) Limpeza Python"
    echo "4) Limpeza Java/Gradle/IDEs JetBrains"
    echo "5) Limpeza Node.js"
    echo "6) Limpeza do Sistema (apt, logs)"
    echo "7) Limpeza Docker"
    echo "8) Analisar extensões antigas dos IDEs"
    echo "9) Sair"
    echo ""
    read -r -p "Escolha uma opção: " choice
    echo ""
}

# ===== Limpeza IDEs VS Code =====
clean_vscode_ides() {
    TOTAL_CLEANED=0

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Limpeza de Cache - IDEs VS Code     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # VS CODE
    echo -e "${GREEN}>>> VS Code${NC}"
    clean_directory "$HOME/.config/Code/CachedExtensionVSIXs" "Cache de extensões VSIX"
    clean_directory "$HOME/.config/Code/CachedData" "Cache de dados compilados"
    clean_directory "$HOME/.config/Code/Cache" "Cache geral"
    clean_directory "$HOME/.config/Code/GPUCache" "Cache GPU"
    clean_directory "$HOME/.config/Code/logs" "Logs"
    clean_directory "$HOME/.config/Code/Crashpad" "Crashpad"
    clean_directory "$HOME/.config/Code/DawnWebGPUCache" "Dawn WebGPU Cache"
    clean_directory "$HOME/.config/Code/DawnGraphiteCache" "Dawn Graphite Cache"
    echo ""

    # CURSOR
    echo -e "${GREEN}>>> Cursor${NC}"
    clean_directory "$HOME/.config/Cursor/CachedExtensionVSIXs" "Cache de extensões VSIX"
    clean_directory "$HOME/.config/Cursor/CachedData" "Cache de dados compilados"
    clean_directory "$HOME/.config/Cursor/Cache" "Cache geral"
    clean_directory "$HOME/.config/Cursor/GPUCache" "Cache GPU"
    clean_directory "$HOME/.config/Cursor/logs" "Logs"
    clean_directory "$HOME/.config/Cursor/Crashpad" "Crashpad"
    clean_directory "$HOME/.config/Cursor/DawnWebGPUCache" "Dawn WebGPU Cache"
    echo ""

    # WINDSURF
    echo -e "${GREEN}>>> Windsurf${NC}"
    clean_directory "$HOME/.config/Windsurf/CachedExtensionVSIXs" "Cache de extensões VSIX"
    clean_directory "$HOME/.config/Windsurf/CachedData" "Cache de dados compilados"
    clean_directory "$HOME/.config/Windsurf/Cache" "Cache geral"
    clean_directory "$HOME/.config/Windsurf/GPUCache" "Cache GPU"
    clean_directory "$HOME/.config/Windsurf/logs" "Logs"
    clean_directory "$HOME/.config/Windsurf/Crashpad" "Crashpad"
    echo ""

    # ANTIGRAVITY (Google)
    echo -e "${GREEN}>>> Antigravity${NC}"
    clean_directory "$HOME/.config/Antigravity/CachedExtensionVSIXs" "Cache de extensões VSIX"
    clean_directory "$HOME/.config/Antigravity/CachedData" "Cache de dados compilados"
    clean_directory "$HOME/.config/Antigravity/Cache" "Cache geral"
    clean_directory "$HOME/.config/Antigravity/GPUCache" "Cache GPU"
    clean_directory "$HOME/.config/Antigravity/logs" "Logs"
    clean_directory "$HOME/.config/Antigravity/Crashpad" "Crashpad"
    echo ""

    # Cache do sistema relacionado
    echo -e "${GREEN}>>> Cache do sistema (VS Code relacionado)${NC}"
    clean_directory "$HOME/.cache/vscode-cpptools" "vscode-cpptools"
    clean_directory "$HOME/.cache/vscode-ripgrep" "vscode-ripgrep"
    clean_directory "$HOME/.cache/cloud-code" "cloud-code"
    echo ""

    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Total liberado (IDEs): ${CYAN}$(format_size "$TOTAL_CLEANED")${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# ===== Limpeza Python =====
clean_python() {
    echo -e "${GREEN}>>> Limpando cache do Python...${NC}"
    if prompt_confirmation "Limpar cache do Python (__pycache__, pip)?"; then
        find ~ -type d -name "__pycache__" -print0 2>/dev/null | xargs -0 rm -rf 2>/dev/null || true
        find ~ -type f -name "*.pyc" -delete 2>/dev/null || true
        if command -v pip >/dev/null 2>&1; then
            pip cache purge -q 2>/dev/null || true
        fi
        echo -e "  ${GREEN}Cache do Python limpo${NC}"
    else
        echo -e "  ${YELLOW}Pulando limpeza do Python${NC}"
    fi
    echo ""
}

# ===== Limpeza Java/Gradle =====
clean_java_gradle() {
    echo -e "${GREEN}>>> Limpando cache do Java/Gradle/IDEs JetBrains...${NC}"
    if prompt_confirmation "Limpar cache do Java/Gradle/IDEs JetBrains?"; then
        rm -rf ~/.m2/repository 2>/dev/null || true
        rm -rf ~/.gradle/caches 2>/dev/null || true
        rm -rf ~/.cache/JetBrains 2>/dev/null || true
        rm -rf ~/.eclipse 2>/dev/null || true
        echo -e "  ${GREEN}Cache do Java/Gradle/IDEs limpo${NC}"
    else
        echo -e "  ${YELLOW}Pulando limpeza do Java/Gradle${NC}"
    fi
    echo ""
}

# ===== Limpeza Node.js =====
clean_nodejs() {
    echo -e "${GREEN}>>> Limpando cache do Node.js...${NC}"
    if prompt_confirmation "Limpar cache do Node.js (npm)?"; then
        if command -v npm >/dev/null 2>&1; then
            npm cache clean --force >/dev/null 2>&1 || true
        fi
        rm -rf ~/.npm/_cacache 2>/dev/null || true
        echo -e "  ${GREEN}Cache do Node.js limpo${NC}"
    else
        echo -e "  ${YELLOW}Pulando limpeza do Node.js${NC}"
    fi
    echo ""
}

# ===== Limpeza Sistema =====
clean_system() {
    echo -e "${GREEN}>>> Limpando pacotes e logs do sistema...${NC}"
    if prompt_confirmation "Limpar pacotes e logs do sistema (requer sudo)?"; then
        echo -e "  ${YELLOW}Solicitando permissões de administrador...${NC}"
        sudo apt clean -y
        sudo apt autoremove -y
        sudo journalctl --vacuum-time=7d
        echo -e "  ${GREEN}Limpeza do sistema concluída${NC}"
    else
        echo -e "  ${YELLOW}Pulando limpeza do sistema${NC}"
    fi
    echo ""
}

# ===== Limpeza Docker =====
clean_docker() {
    echo -e "${GREEN}>>> Limpando cache do Docker...${NC}"
    if prompt_confirmation "Limpar cache do Docker (pode remover volumes/imagens não usadas)?"; then
        if command -v docker >/dev/null 2>&1; then
            docker system prune -af >/dev/null 2>&1 || true
            docker volume prune -f >/dev/null 2>&1 || true
            echo -e "  ${GREEN}Cache do Docker limpo${NC}"
        else
            echo -e "  ${YELLOW}Docker não encontrado${NC}"
        fi
    else
        echo -e "  ${YELLOW}Pulando limpeza do Docker${NC}"
    fi
    echo ""
}

# ===== Análise de Extensões =====
analyze_all_extensions() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Analise de Extensoes Antigas        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    analyze_extensions "$HOME/.vscode/extensions" "VS Code"
    analyze_extensions "$HOME/.cursor/extensions" "Cursor"
    analyze_extensions "$HOME/.windsurf/extensions" "Windsurf"
    analyze_extensions "$HOME/.antigravity/extensions" "Antigravity"

    echo -e "${BLUE}========================================${NC}"
    echo -e "${YELLOW}DICA: Para remover uma extensao antiga manualmente:${NC}"
    echo -e "  rm -rf ~/.vscode/extensions/NOME-DA-EXTENSAO"
    echo ""
    echo -e "${YELLOW}DICA: Para limpar workspaceStorage antigos:${NC}"
    echo -e "  ls -la ~/.config/Code/User/workspaceStorage/"
    echo -e "  rm -rf ~/.config/Code/User/workspaceStorage/HASH_DO_PROJETO"
    echo -e "${BLUE}========================================${NC}"
}

# ===== Limpeza Completa =====
clean_all() {
    clean_vscode_ides
    clean_python
    clean_java_gradle
    clean_nodejs
    clean_system
    clean_docker
    analyze_all_extensions
}

# ===== Main =====
main() {
    # Se passou argumento --all, executa tudo sem menu
    if [[ "${1:-}" == "--all" ]]; then
        clean_all
        exit 0
    fi

    # Se passou argumento --vscode, limpa só IDEs
    if [[ "${1:-}" == "--vscode" ]]; then
        clean_vscode_ides
        exit 0
    fi

    # Se passou argumento --analyze, só analisa extensões
    if [[ "${1:-}" == "--analyze" ]]; then
        analyze_all_extensions
        exit 0
    fi

    # Menu interativo
    while true; do
        show_menu
        case $choice in
            1) clean_all ;;
            2) clean_vscode_ides ;;
            3) clean_python ;;
            4) clean_java_gradle ;;
            5) clean_nodejs ;;
            6) clean_system ;;
            7) clean_docker ;;
            8) analyze_all_extensions ;;
            9) echo "Saindo..."; exit 0 ;;
            *) echo -e "${RED}Opção inválida!${NC}" ;;
        esac
        echo ""
        read -r -p "Pressione Enter para continuar..."
        clear
    done
}

main "$@"
