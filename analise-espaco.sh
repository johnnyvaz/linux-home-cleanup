#!/bin/bash
#
# analise-espaco.sh - Análise de distribuição de espaço no /home
# Autor: Johnny
# Data: 2025-11-21
#
# Funcionalidades:
# - Mostra distribuição de espaço por diretório
# - Identifica arquivos grandes
# - Sugere compactação, backup e envio para nuvem
# - Detecta arquivos duplicados
# - Identifica arquivos antigos sem acesso
#

set -euo pipefail

# ===== Cores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ===== Config =====
HOME_DIR="${1:-$HOME}"
REPORT_DIR="$HOME/Documentos/limpeza/reports"
REPORT_FILE="$REPORT_DIR/analise_$(date +%Y%m%d_%H%M%S).txt"
MIN_SIZE_MB=100  # Tamanho mínimo para sugestões (MB)
OLD_DAYS=180     # Dias sem acesso para considerar arquivo antigo

# ===== Funções =====
format_size() {
    numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "${1}B"
}

header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

subheader() {
    echo -e "\n${GREEN}>>> $1${NC}\n"
}

# ===== Início =====
mkdir -p "$REPORT_DIR"

clear
echo -e "${BOLD}${MAGENTA}"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║     ANÁLISE DE ESPAÇO EM DISCO - HOME                     ║"
echo "  ║     Analisando: $HOME_DIR"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ===== 1. Visão Geral do Disco =====
header "1. VISÃO GERAL DO DISCO"

echo -e "${YELLOW}Uso do sistema de arquivos:${NC}"
df -h "$HOME_DIR" | tail -1 | awk '{
    printf "  Dispositivo: %s\n", $1
    printf "  Total:       %s\n", $2
    printf "  Usado:       %s (%s)\n", $3, $5
    printf "  Disponível:  %s\n", $4
}'

TOTAL_HOME=$(du -sb "$HOME_DIR" 2>/dev/null | cut -f1)
echo -e "\n${YELLOW}Tamanho total do HOME:${NC} $(format_size "$TOTAL_HOME")"

# ===== 2. Distribuição por Diretório (Top 20) =====
header "2. DISTRIBUIÇÃO POR DIRETÓRIO (Top 20)"

echo -e "${YELLOW}Diretórios ordenados por tamanho:${NC}\n"
printf "  ${BOLD}%-10s  %-6s  %s${NC}\n" "TAMANHO" "%" "DIRETÓRIO"
echo "  ────────────────────────────────────────────────────────"

du -sb "$HOME_DIR"/*/ 2>/dev/null | sort -rn | head -20 | while read -r size dir; do
    if [ "$TOTAL_HOME" -gt 0 ]; then
        pct=$((size * 100 / TOTAL_HOME))
    else
        pct=0
    fi
    size_human=$(format_size "$size")
    dir_name=$(basename "$dir")

    # Colorir baseado no tamanho
    if [ "$size" -gt 5368709120 ]; then  # > 5GB
        color=$RED
    elif [ "$size" -gt 1073741824 ]; then  # > 1GB
        color=$YELLOW
    else
        color=$NC
    fi

    printf "  ${color}%-10s  %5d%%  %s${NC}\n" "$size_human" "$pct" "$dir_name"
done

# ===== 3. Arquivos Grandes (>100MB) =====
header "3. ARQUIVOS GRANDES (>${MIN_SIZE_MB}MB)"

echo -e "${YELLOW}Top 30 maiores arquivos:${NC}\n"
printf "  ${BOLD}%-10s  %-12s  %s${NC}\n" "TAMANHO" "MODIFICADO" "ARQUIVO"
echo "  ────────────────────────────────────────────────────────"

find "$HOME_DIR" -type f -size +"${MIN_SIZE_MB}"M -print0 2>/dev/null | \
    xargs -0 -I{} stat --format="%s %Y %n" {} 2>/dev/null | \
    sort -rn | head -30 | while read -r size mtime filepath; do
        size_human=$(format_size "$size")
        mod_date=$(date -d "@$mtime" +"%Y-%m-%d")
        # Encurtar path se muito longo
        short_path="${filepath/#$HOME_DIR/~}"
        if [ ${#short_path} -gt 50 ]; then
            short_path="...${short_path: -47}"
        fi
        printf "  %-10s  %-12s  %s\n" "$size_human" "$mod_date" "$short_path"
done

# ===== 4. Análise por Tipo de Arquivo =====
header "4. ANÁLISE POR TIPO DE ARQUIVO"

subheader "Vídeos (.mp4, .mkv, .avi, .mov, .webm)"
VIDEO_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
VIDEO_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) 2>/dev/null | wc -l)
echo -e "  Total: ${CYAN}$(format_size "$VIDEO_SIZE")${NC} em ${CYAN}$VIDEO_COUNT${NC} arquivos"

subheader "Imagens (.jpg, .png, .gif, .raw, .psd)"
IMG_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.raw" -o -iname "*.psd" -o -iname "*.bmp" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
IMG_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.raw" -o -iname "*.psd" -o -iname "*.bmp" \) 2>/dev/null | wc -l)
echo -e "  Total: ${CYAN}$(format_size "$IMG_SIZE")${NC} em ${CYAN}$IMG_COUNT${NC} arquivos"

subheader "Áudio (.mp3, .flac, .wav, .ogg)"
AUDIO_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
AUDIO_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" \) 2>/dev/null | wc -l)
echo -e "  Total: ${CYAN}$(format_size "$AUDIO_SIZE")${NC} em ${CYAN}$AUDIO_COUNT${NC} arquivos"

subheader "Documentos (.pdf, .doc, .xls, .ppt)"
DOC_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.pdf" -o -iname "*.doc*" -o -iname "*.xls*" -o -iname "*.ppt*" -o -iname "*.odt" -o -iname "*.ods" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
DOC_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.pdf" -o -iname "*.doc*" -o -iname "*.xls*" -o -iname "*.ppt*" -o -iname "*.odt" -o -iname "*.ods" \) 2>/dev/null | wc -l)
echo -e "  Total: ${CYAN}$(format_size "$DOC_SIZE")${NC} em ${CYAN}$DOC_COUNT${NC} arquivos"

subheader "Compactados (.zip, .tar, .gz, .rar, .7z)"
ARCHIVE_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.zip" -o -iname "*.tar*" -o -iname "*.gz" -o -iname "*.rar" -o -iname "*.7z" -o -iname "*.bz2" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
ARCHIVE_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.zip" -o -iname "*.tar*" -o -iname "*.gz" -o -iname "*.rar" -o -iname "*.7z" -o -iname "*.bz2" \) 2>/dev/null | wc -l)
echo -e "  Total: ${CYAN}$(format_size "$ARCHIVE_SIZE")${NC} em ${CYAN}$ARCHIVE_COUNT${NC} arquivos"

subheader "Código-fonte e projetos (node_modules, .git, vendor)"
NODE_SIZE=$(find "$HOME_DIR" -type d -name "node_modules" -exec du -sb {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
NODE_COUNT=$(find "$HOME_DIR" -type d -name "node_modules" 2>/dev/null | wc -l)
echo -e "  node_modules: ${CYAN}$(format_size "$NODE_SIZE")${NC} em ${CYAN}$NODE_COUNT${NC} diretórios"

GIT_SIZE=$(find "$HOME_DIR" -type d -name ".git" -exec du -sb {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
GIT_COUNT=$(find "$HOME_DIR" -type d -name ".git" 2>/dev/null | wc -l)
echo -e "  .git:         ${CYAN}$(format_size "$GIT_SIZE")${NC} em ${CYAN}$GIT_COUNT${NC} repositórios"

# ===== 5. Arquivos Antigos (sem acesso há 180+ dias) =====
header "5. ARQUIVOS ANTIGOS (>${OLD_DAYS} dias sem acesso, >50MB)"

echo -e "${YELLOW}Arquivos grandes não acessados recentemente:${NC}\n"
printf "  ${BOLD}%-10s  %-12s  %s${NC}\n" "TAMANHO" "ÚLTIMO ACESSO" "ARQUIVO"
echo "  ────────────────────────────────────────────────────────"

find "$HOME_DIR" -type f -size +50M -atime +"${OLD_DAYS}" -print0 2>/dev/null | \
    xargs -0 -I{} stat --format="%s %X %n" {} 2>/dev/null | \
    sort -rn | head -20 | while read -r size atime filepath; do
        size_human=$(format_size "$size")
        access_date=$(date -d "@$atime" +"%Y-%m-%d")
        short_path="${filepath/#$HOME_DIR/~}"
        if [ ${#short_path} -gt 50 ]; then
            short_path="...${short_path: -47}"
        fi
        printf "  %-10s  %-12s  %s\n" "$size_human" "$access_date" "$short_path"
done

# ===== 6. Sugestões de Otimização =====
header "6. SUGESTÕES DE OTIMIZAÇÃO"

echo -e "${BOLD}${GREEN}A) COMPACTAÇÃO LOCAL${NC}"
echo ""
echo "  Arquivos que podem ser compactados para economizar espaço:"
echo ""

# Sugerir compactação de node_modules antigos
if [ "$NODE_SIZE" -gt 1073741824 ]; then  # > 1GB
    echo -e "  ${YELLOW}1. node_modules ($(format_size "$NODE_SIZE"))${NC}"
    echo "     Projetos inativos podem ter node_modules removidos."
    echo "     Comando: find ~/projetos -name 'node_modules' -type d -mtime +90 -exec rm -rf {} +"
    echo ""
fi

# Sugerir compactação de vídeos grandes
if [ "$VIDEO_SIZE" -gt 1073741824 ]; then  # > 1GB
    echo -e "  ${YELLOW}2. Vídeos ($(format_size "$VIDEO_SIZE"))${NC}"
    echo "     Considere recomprimir com ffmpeg (H.265/HEVC economiza ~50%):"
    echo "     Comando: ffmpeg -i video.mp4 -c:v libx265 -crf 28 video_compactado.mp4"
    echo ""
fi

# Sugerir compactação de imagens RAW/PSD
RAW_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.raw" -o -iname "*.psd" -o -iname "*.xcf" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
if [ "$RAW_SIZE" -gt 536870912 ]; then  # > 500MB
    echo -e "  ${YELLOW}3. Imagens RAW/PSD ($(format_size "$RAW_SIZE"))${NC}"
    echo "     Arquivos editáveis ocupam muito espaço. Considere:"
    echo "     - Exportar versões finais em JPEG/PNG"
    echo "     - Arquivar originais em disco externo"
    echo ""
fi

echo -e "${BOLD}${GREEN}B) BACKUP E NUVEM${NC}"
echo ""
echo "  Sugestões para mover arquivos para nuvem/backup:"
echo ""

echo -e "  ${YELLOW}1. Google Drive (15GB grátis)${NC}"
echo "     Ideal para: Documentos, fotos, arquivos de trabalho"
echo "     Ferramenta: rclone (https://rclone.org)"
echo "     Comando: rclone sync ~/Documentos gdrive:Backup/Documentos"
echo ""

echo -e "  ${YELLOW}2. Backblaze B2 (\$0.005/GB/mês)${NC}"
echo "     Ideal para: Backups grandes, arquivos frios"
echo "     Ferramenta: rclone ou backblaze-b2"
echo "     Comando: rclone sync ~/Videos b2:meu-bucket/Videos"
echo ""

echo -e "  ${YELLOW}3. Amazon S3 Glacier (\$0.004/GB/mês)${NC}"
echo "     Ideal para: Arquivos que você raramente acessa"
echo "     Use para: Vídeos antigos, backups de projetos finalizados"
echo ""

echo -e "  ${YELLOW}4. Disco Externo / NAS${NC}"
echo "     Ideal para: Mídia pessoal, backups completos"
echo "     Comando: rsync -avh --progress ~/Videos /media/externo/Videos"
echo ""

echo -e "${BOLD}${GREEN}C) LIMPEZA SEGURA${NC}"
echo ""

echo -e "  ${YELLOW}1. Downloads antigos${NC}"
DOWNLOADS_SIZE=$(du -sb "$HOME_DIR/Downloads" 2>/dev/null | cut -f1 || echo 0)
if [ "$DOWNLOADS_SIZE" -gt 1073741824 ]; then
    echo "     Pasta Downloads tem $(format_size "$DOWNLOADS_SIZE")"
    echo "     Comando: find ~/Downloads -type f -mtime +90 -delete"
    echo ""
fi

echo -e "  ${YELLOW}2. Lixeira${NC}"
TRASH_SIZE=$(du -sb "$HOME_DIR/.local/share/Trash" 2>/dev/null | cut -f1 || echo 0)
if [ "$TRASH_SIZE" -gt 104857600 ]; then  # > 100MB
    echo "     Lixeira tem $(format_size "$TRASH_SIZE")"
    echo "     Comando: rm -rf ~/.local/share/Trash/*"
    echo ""
fi

echo -e "  ${YELLOW}3. Cache do navegador${NC}"
CHROME_CACHE=$(du -sb "$HOME_DIR/.cache/google-chrome" 2>/dev/null | cut -f1 || echo 0)
FIREFOX_CACHE=$(du -sb "$HOME_DIR/.cache/mozilla" 2>/dev/null | cut -f1 || echo 0)
BROWSER_CACHE=$((CHROME_CACHE + FIREFOX_CACHE))
if [ "$BROWSER_CACHE" -gt 524288000 ]; then  # > 500MB
    echo "     Cache de navegadores: $(format_size "$BROWSER_CACHE")"
    echo "     Limpe pelo próprio navegador ou:"
    echo "     Comando: rm -rf ~/.cache/google-chrome/Default/Cache/*"
    echo ""
fi

echo -e "  ${YELLOW}4. Thumbnails${NC}"
THUMB_SIZE=$(du -sb "$HOME_DIR/.cache/thumbnails" 2>/dev/null | cut -f1 || echo 0)
if [ "$THUMB_SIZE" -gt 104857600 ]; then  # > 100MB
    echo "     Thumbnails: $(format_size "$THUMB_SIZE")"
    echo "     Comando: rm -rf ~/.cache/thumbnails/*"
    echo ""
fi

# ===== 7. Resumo Final =====
header "7. RESUMO - POTENCIAL DE ECONOMIA"

POTENTIAL_SAVE=0

# Calcular potencial
if [ "$NODE_SIZE" -gt 0 ]; then
    POTENTIAL_SAVE=$((POTENTIAL_SAVE + NODE_SIZE / 2))
fi
if [ "$TRASH_SIZE" -gt 0 ]; then
    POTENTIAL_SAVE=$((POTENTIAL_SAVE + TRASH_SIZE))
fi
if [ "$BROWSER_CACHE" -gt 0 ]; then
    POTENTIAL_SAVE=$((POTENTIAL_SAVE + BROWSER_CACHE))
fi
if [ "$THUMB_SIZE" -gt 0 ]; then
    POTENTIAL_SAVE=$((POTENTIAL_SAVE + THUMB_SIZE))
fi

echo -e "  ${BOLD}Espaço atual usado:${NC}        $(format_size "$TOTAL_HOME")"
echo -e "  ${BOLD}Potencial de economia:${NC}     ${GREEN}~$(format_size "$POTENTIAL_SAVE")${NC} (limpeza básica)"
echo ""
echo -e "  ${BOLD}Candidatos para nuvem/backup:${NC}"
echo -e "    - Vídeos:     $(format_size "$VIDEO_SIZE")"
echo -e "    - Imagens:    $(format_size "$IMG_SIZE")"
echo -e "    - Áudio:      $(format_size "$AUDIO_SIZE")"
echo -e "    - Documentos: $(format_size "$DOC_SIZE")"
echo ""

# ===== Salvar relatório =====
header "RELATÓRIO SALVO"
echo -e "  Arquivo: ${CYAN}$REPORT_FILE${NC}"
echo ""

# Executar novamente redirecionando para arquivo (sem cores)
{
    echo "ANÁLISE DE ESPAÇO - $(date)"
    echo "Diretório: $HOME_DIR"
    echo "========================================"
    echo ""
    echo "DISTRIBUIÇÃO POR DIRETÓRIO (Top 20):"
    du -sh "$HOME_DIR"/*/ 2>/dev/null | sort -rh | head -20
    echo ""
    echo "ARQUIVOS GRANDES (>${MIN_SIZE_MB}MB):"
    find "$HOME_DIR" -type f -size +${MIN_SIZE_MB}M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh | head -30
    echo ""
    echo "RESUMO:"
    echo "  Total HOME: $(format_size "$TOTAL_HOME")"
    echo "  Vídeos: $(format_size "$VIDEO_SIZE")"
    echo "  Imagens: $(format_size "$IMG_SIZE")"
    echo "  Áudio: $(format_size "$AUDIO_SIZE")"
    echo "  Documentos: $(format_size "$DOC_SIZE")"
    echo "  node_modules: $(format_size "$NODE_SIZE")"
} > "$REPORT_FILE"

echo -e "${GREEN}Análise concluída!${NC}"
