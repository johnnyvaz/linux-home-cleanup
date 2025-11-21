#!/bin/bash
#
# limpeza-profunda.sh - Limpeza profunda do sistema
# Autor: Johnny
# Data: 2025-11-21
#
# Limpa: Docker, Snaps antigos, Cache do sistema
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

TOTAL_FREED=0

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

header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

# ============================================
# 1. DOCKER
# ============================================
clean_docker() {
    header "1. LIMPEZA DO DOCKER"

    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker não instalado, pulando...${NC}"
        return
    fi

    echo -e "${YELLOW}Uso atual do Docker:${NC}"
    docker system df 2>/dev/null || true
    echo ""

    # Limpar recursos não utilizados
    if prompt_confirmation "Limpar imagens, containers e volumes não utilizados?"; then
        echo -e "${GREEN}Limpando recursos Docker...${NC}"

        # Parar todos os containers primeiro
        docker stop $(docker ps -q) 2>/dev/null || true

        # Limpar tudo que não está em uso
        docker system prune -af --volumes 2>/dev/null || true

        echo -e "${GREEN}Recursos Docker limpos!${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Sobre o Docker.raw (disco virtual):${NC}"

    DOCKER_RAW="$HOME/.docker/desktop/vms/0/data/Docker.raw"
    if [ -f "$DOCKER_RAW" ]; then
        RAW_SIZE=$(stat -c%s "$DOCKER_RAW" 2>/dev/null || echo 0)
        echo -e "  Tamanho atual: ${RED}$(format_size "$RAW_SIZE")${NC}"
        echo ""
        echo -e "${YELLOW}Para reduzir o Docker.raw você tem 3 opções:${NC}"
        echo ""
        echo -e "  ${BOLD}Opção 1 - Via Docker Desktop (Recomendado):${NC}"
        echo "    1. Abra Docker Desktop"
        echo "    2. Vá em Settings > Resources > Advanced"
        echo "    3. Reduza 'Virtual disk limit' para um valor menor (ex: 32GB)"
        echo "    4. Clique 'Apply & Restart'"
        echo ""
        echo -e "  ${BOLD}Opção 2 - Reset completo (APAGA TUDO):${NC}"
        echo "    docker system prune -af --volumes"
        echo "    rm -rf ~/.docker/desktop/vms/0/data/Docker.raw"
        echo "    # Reinicie o Docker Desktop"
        echo ""
        echo -e "  ${BOLD}Opção 3 - Compactar com QEMU (Avançado):${NC}"
        echo "    # Pare o Docker Desktop primeiro!"
        echo "    qemu-img convert -O raw Docker.raw Docker-new.raw"
        echo "    mv Docker-new.raw Docker.raw"
        echo ""

        if prompt_confirmation "Deseja fazer o RESET COMPLETO do Docker? (APAGA TODAS IMAGENS/VOLUMES)"; then
            echo -e "${RED}Parando Docker Desktop...${NC}"
            systemctl --user stop docker-desktop 2>/dev/null || true
            pkill -f "Docker Desktop" 2>/dev/null || true
            sleep 3

            echo -e "${RED}Removendo Docker.raw...${NC}"
            rm -f "$DOCKER_RAW"

            TOTAL_FREED=$((TOTAL_FREED + RAW_SIZE))
            echo -e "${GREEN}Docker.raw removido! Liberado: $(format_size "$RAW_SIZE")${NC}"
            echo -e "${YELLOW}Reinicie o Docker Desktop para criar um novo disco.${NC}"
        fi
    fi
}

# ============================================
# 2. SNAPS ANTIGOS
# ============================================
clean_snaps() {
    header "2. LIMPEZA DE SNAPS ANTIGOS"

    if ! command -v snap &> /dev/null; then
        echo -e "${YELLOW}Snap não instalado, pulando...${NC}"
        return
    fi

    echo -e "${YELLOW}Revisões desabilitadas (podem ser removidas):${NC}"
    snap list --all | awk '/disabled/{print "  " $1 " (rev " $3 ")"}' || true
    echo ""

    DISABLED_COUNT=$(snap list --all 2>/dev/null | grep -c disabled || echo 0)
    echo -e "Total: ${CYAN}$DISABLED_COUNT${NC} revisões desabilitadas"
    echo ""

    # Mostrar maiores snaps
    echo -e "${YELLOW}Maiores diretórios em ~/snap:${NC}"
    du -sh ~/snap/*/ 2>/dev/null | sort -rh | head -10
    echo ""

    if prompt_confirmation "Remover todas as revisões desabilitadas de snaps?"; then
        echo -e "${GREEN}Removendo snaps desabilitados...${NC}"

        snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            if [ -n "$snapname" ] && [ -n "$revision" ]; then
                size_before=$(du -sb ~/snap/$snapname 2>/dev/null | cut -f1 || echo 0)
                echo "  Removendo $snapname (rev $revision)..."
                sudo snap remove "$snapname" --revision="$revision" 2>/dev/null || true
                size_after=$(du -sb ~/snap/$snapname 2>/dev/null | cut -f1 || echo 0)
                freed=$((size_before - size_after))
                if [ "$freed" -gt 0 ]; then
                    TOTAL_FREED=$((TOTAL_FREED + freed))
                fi
            fi
        done

        echo -e "${GREEN}Snaps desabilitados removidos!${NC}"
    fi

    # VS Code snap específico (muito grande)
    VSCODE_SNAP_SIZE=$(du -sb ~/snap/code 2>/dev/null | cut -f1 || echo 0)
    if [ "$VSCODE_SNAP_SIZE" -gt 10737418240 ]; then  # > 10GB
        echo ""
        echo -e "${RED}ATENÇÃO: ~/snap/code tem $(format_size "$VSCODE_SNAP_SIZE")${NC}"
        echo -e "${YELLOW}Isso é muito grande! Provavelmente tem cache/extensões duplicados.${NC}"
        echo ""
        echo "Estrutura:"
        du -sh ~/snap/code/*/ 2>/dev/null
        echo ""

        if prompt_confirmation "Limpar cache do VS Code snap (mantém configurações)?"; then
            # Limpar cache dentro do snap
            rm -rf ~/snap/code/*/Cache 2>/dev/null || true
            rm -rf ~/snap/code/*/CachedData 2>/dev/null || true
            rm -rf ~/snap/code/*/CachedExtensionVSIXs 2>/dev/null || true
            rm -rf ~/snap/code/*/GPUCache 2>/dev/null || true
            rm -rf ~/snap/code/*/logs 2>/dev/null || true
            rm -rf ~/snap/code/*/.config/Code/Cache 2>/dev/null || true
            rm -rf ~/snap/code/*/.config/Code/CachedData 2>/dev/null || true
            rm -rf ~/snap/code/*/.config/Code/CachedExtensionVSIXs 2>/dev/null || true
            echo -e "${GREEN}Cache do VS Code snap limpo!${NC}"
        fi
    fi
}

# ============================================
# 3. CACHE DO SISTEMA
# ============================================
clean_cache() {
    header "3. LIMPEZA DO ~/.cache"

    echo -e "${YELLOW}Maiores diretórios em ~/.cache:${NC}"
    du -sh ~/.cache/*/ 2>/dev/null | sort -rh | head -15
    echo ""

    CACHE_TOTAL=$(du -sb ~/.cache 2>/dev/null | cut -f1 || echo 0)
    echo -e "Total: ${CYAN}$(format_size "$CACHE_TOTAL")${NC}"
    echo ""

    # uv (gerenciador de pacotes Python)
    UV_SIZE=$(get_dir_size "$HOME/.cache/uv")
    if [ "$UV_SIZE" -gt 1073741824 ]; then  # > 1GB
        echo -e "${YELLOW}Cache do uv (Python): $(format_size "$UV_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do uv?"; then
            rm -rf ~/.cache/uv/*
            TOTAL_FREED=$((TOTAL_FREED + UV_SIZE))
            echo -e "${GREEN}Cache uv limpo!${NC}"
        fi
    fi

    # Brave Browser
    BRAVE_SIZE=$(get_dir_size "$HOME/.cache/BraveSoftware")
    if [ "$BRAVE_SIZE" -gt 1073741824 ]; then
        echo -e "${YELLOW}Cache do Brave: $(format_size "$BRAVE_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Brave?"; then
            rm -rf ~/.cache/BraveSoftware/Brave-Browser/Default/Cache/*
            rm -rf ~/.cache/BraveSoftware/Brave-Browser/Default/Code\ Cache/*
            TOTAL_FREED=$((TOTAL_FREED + BRAVE_SIZE / 2))
            echo -e "${GREEN}Cache Brave limpo!${NC}"
        fi
    fi

    # Puppeteer
    PUPPETEER_SIZE=$(get_dir_size "$HOME/.cache/puppeteer")
    if [ "$PUPPETEER_SIZE" -gt 536870912 ]; then  # > 500MB
        echo -e "${YELLOW}Cache do Puppeteer: $(format_size "$PUPPETEER_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Puppeteer?"; then
            rm -rf ~/.cache/puppeteer/*
            TOTAL_FREED=$((TOTAL_FREED + PUPPETEER_SIZE))
            echo -e "${GREEN}Cache Puppeteer limpo!${NC}"
        fi
    fi

    # Playwright
    PLAYWRIGHT_SIZE=$(get_dir_size "$HOME/.cache/ms-playwright")
    if [ "$PLAYWRIGHT_SIZE" -gt 536870912 ]; then
        echo -e "${YELLOW}Cache do Playwright: $(format_size "$PLAYWRIGHT_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Playwright?"; then
            rm -rf ~/.cache/ms-playwright/*
            rm -rf ~/.cache/ms-playwright-go/*
            TOTAL_FREED=$((TOTAL_FREED + PLAYWRIGHT_SIZE))
            echo -e "${GREEN}Cache Playwright limpo!${NC}"
        fi
    fi

    # TypeScript
    TS_SIZE=$(get_dir_size "$HOME/.cache/typescript")
    if [ "$TS_SIZE" -gt 104857600 ]; then  # > 100MB
        echo -e "${YELLOW}Cache do TypeScript: $(format_size "$TS_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do TypeScript?"; then
            rm -rf ~/.cache/typescript/*
            TOTAL_FREED=$((TOTAL_FREED + TS_SIZE))
            echo -e "${GREEN}Cache TypeScript limpo!${NC}"
        fi
    fi

    # Yarn
    YARN_SIZE=$(get_dir_size "$HOME/.cache/yarn")
    if [ "$YARN_SIZE" -gt 104857600 ]; then
        echo -e "${YELLOW}Cache do Yarn: $(format_size "$YARN_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Yarn?"; then
            yarn cache clean 2>/dev/null || rm -rf ~/.cache/yarn/*
            TOTAL_FREED=$((TOTAL_FREED + YARN_SIZE))
            echo -e "${GREEN}Cache Yarn limpo!${NC}"
        fi
    fi

    # pnpm
    PNPM_SIZE=$(get_dir_size "$HOME/.cache/pnpm")
    if [ "$PNPM_SIZE" -gt 104857600 ]; then
        echo -e "${YELLOW}Cache do pnpm: $(format_size "$PNPM_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do pnpm?"; then
            pnpm store prune 2>/dev/null || rm -rf ~/.cache/pnpm/*
            TOTAL_FREED=$((TOTAL_FREED + PNPM_SIZE))
            echo -e "${GREEN}Cache pnpm limpo!${NC}"
        fi
    fi

    # JetBrains
    JB_SIZE=$(get_dir_size "$HOME/.cache/JetBrains")
    if [ "$JB_SIZE" -gt 104857600 ]; then
        echo -e "${YELLOW}Cache do JetBrains: $(format_size "$JB_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do JetBrains?"; then
            rm -rf ~/.cache/JetBrains/*
            TOTAL_FREED=$((TOTAL_FREED + JB_SIZE))
            echo -e "${GREEN}Cache JetBrains limpo!${NC}"
        fi
    fi

    # Thumbnails
    THUMB_SIZE=$(get_dir_size "$HOME/.cache/thumbnails")
    if [ "$THUMB_SIZE" -gt 52428800 ]; then  # > 50MB
        echo -e "${YELLOW}Thumbnails: $(format_size "$THUMB_SIZE")${NC}"
        if prompt_confirmation "Limpar thumbnails?"; then
            rm -rf ~/.cache/thumbnails/*
            TOTAL_FREED=$((TOTAL_FREED + THUMB_SIZE))
            echo -e "${GREEN}Thumbnails limpos!${NC}"
        fi
    fi

    # Tracker (indexador do GNOME)
    TRACKER_SIZE=$(get_dir_size "$HOME/.cache/tracker3")
    if [ "$TRACKER_SIZE" -gt 536870912 ]; then
        echo -e "${YELLOW}Cache do Tracker: $(format_size "$TRACKER_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Tracker (será reconstruído)?"; then
            tracker3 reset -s -r 2>/dev/null || rm -rf ~/.cache/tracker3/*
            TOTAL_FREED=$((TOTAL_FREED + TRACKER_SIZE))
            echo -e "${GREEN}Cache Tracker limpo!${NC}"
        fi
    fi

    # node-gyp
    NODEGYP_SIZE=$(get_dir_size "$HOME/.cache/node-gyp")
    if [ "$NODEGYP_SIZE" -gt 52428800 ]; then
        echo -e "${YELLOW}Cache do node-gyp: $(format_size "$NODEGYP_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do node-gyp?"; then
            rm -rf ~/.cache/node-gyp/*
            TOTAL_FREED=$((TOTAL_FREED + NODEGYP_SIZE))
            echo -e "${GREEN}Cache node-gyp limpo!${NC}"
        fi
    fi

    # Prisma
    PRISMA_SIZE=$(get_dir_size "$HOME/.cache/prisma")
    if [ "$PRISMA_SIZE" -gt 104857600 ]; then
        echo -e "${YELLOW}Cache do Prisma: $(format_size "$PRISMA_SIZE")${NC}"
        if prompt_confirmation "Limpar cache do Prisma?"; then
            rm -rf ~/.cache/prisma/*
            TOTAL_FREED=$((TOTAL_FREED + PRISMA_SIZE))
            echo -e "${GREEN}Cache Prisma limpo!${NC}"
        fi
    fi
}

# ============================================
# 4. LIMPEZA APT (requer sudo)
# ============================================
clean_apt() {
    header "4. LIMPEZA DO SISTEMA (APT)"

    if prompt_confirmation "Limpar cache do APT e pacotes órfãos? (requer sudo)"; then
        echo -e "${GREEN}Limpando APT...${NC}"
        sudo apt clean -y
        sudo apt autoremove -y
        sudo apt autoclean -y
        echo -e "${GREEN}APT limpo!${NC}"
    fi

    if prompt_confirmation "Limpar logs antigos do journalctl? (requer sudo)"; then
        echo -e "${GREEN}Limpando logs...${NC}"
        sudo journalctl --vacuum-time=7d
        echo -e "${GREEN}Logs limpos!${NC}"
    fi
}

# ============================================
# MAIN
# ============================================
main() {
    echo -e "${BOLD}${BLUE}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║           LIMPEZA PROFUNDA DO SISTEMA                     ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    clean_docker
    clean_snaps
    clean_cache
    clean_apt

    header "RESUMO FINAL"
    echo -e "${GREEN}Total aproximado liberado: ${BOLD}$(format_size "$TOTAL_FREED")${NC}"
    echo ""
    echo -e "${YELLOW}Verificando espaço atual:${NC}"
    df -h /home
    echo ""
    echo -e "${GREEN}Limpeza concluída!${NC}"
}

main "$@"
