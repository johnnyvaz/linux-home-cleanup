#!/bin/bash
#
# analise-ia.sh - Gera relatório estruturado para análise com IA
# Autor: Johnny
# Data: 2025-11-21
#
# Gera um relatório em formato texto/markdown otimizado para ser analisado
# por assistentes de IA (ChatGPT, Claude, Gemini) que podem fornecer
# recomendações personalizadas de limpeza.
#
# Uso:
#   ./analise-ia.sh > relatorio.txt
#   # Cole o conteúdo no seu assistente de IA preferido
#

set -euo pipefail

HOME_DIR="${1:-$HOME}"

# ===== Funções =====
format_size() {
    numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "${1}B"
}

get_size_bytes() {
    du -sb "$1" 2>/dev/null | cut -f1 || echo "0"
}

# ===== Header =====
cat << 'EOF'
# Relatório de Análise do Sistema Linux

Este relatório foi gerado automaticamente para análise por assistentes de IA.
Por favor, analise os dados abaixo e forneça recomendações de:
1. Quais diretórios/arquivos podem ser limpos com segurança
2. Quais devem ser mantidos e por quê
3. Estimativa de espaço que pode ser liberado
4. Ordem de prioridade para limpeza

---

EOF

# ===== Info do Sistema =====
echo "## Informações do Sistema"
echo ""
echo "- **Data:** $(date '+%Y-%m-%d %H:%M')"
echo "- **Hostname:** $(hostname)"
echo "- **Usuário:** $USER"
echo "- **Distro:** $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "- **Kernel:** $(uname -r)"
echo ""

# ===== Disco =====
echo "## Uso do Disco"
echo ""
echo '```'
df -h "$HOME_DIR" | head -1
df -h "$HOME_DIR" | tail -1
echo '```'
echo ""

TOTAL_HOME=$(get_size_bytes "$HOME_DIR")
echo "- **Tamanho total do HOME:** $(format_size $TOTAL_HOME)"
echo ""

# ===== Top Diretórios =====
echo "## Maiores Diretórios no HOME (Top 25)"
echo ""
echo "| Tamanho | % | Diretório |"
echo "|---------|---|-----------|"

du -sb "$HOME_DIR"/*/ 2>/dev/null | sort -rn | head -25 | while read size dir; do
    if [ "$TOTAL_HOME" -gt 0 ]; then
        pct=$((size * 100 / TOTAL_HOME))
    else
        pct=0
    fi
    size_human=$(format_size "$size")
    dir_name=$(basename "$dir")
    echo "| $size_human | $pct% | $dir_name |"
done

echo ""

# ===== Cache =====
echo "## Detalhamento do ~/.cache"
echo ""

if [ -d "$HOME_DIR/.cache" ]; then
    CACHE_SIZE=$(get_size_bytes "$HOME_DIR/.cache")
    echo "**Tamanho total:** $(format_size $CACHE_SIZE)"
    echo ""
    echo "| Tamanho | Diretório |"
    echo "|---------|-----------|"
    du -sb "$HOME_DIR/.cache"/*/ 2>/dev/null | sort -rn | head -15 | while read size dir; do
        size_human=$(format_size "$size")
        dir_name=$(basename "$dir")
        echo "| $size_human | $dir_name |"
    done
    echo ""
fi

# ===== Config (IDEs) =====
echo "## Detalhamento do ~/.config (IDEs e Apps)"
echo ""

if [ -d "$HOME_DIR/.config" ]; then
    echo "| Tamanho | Aplicativo |"
    echo "|---------|------------|"
    du -sb "$HOME_DIR/.config"/*/ 2>/dev/null | sort -rn | head -15 | while read size dir; do
        size_human=$(format_size "$size")
        dir_name=$(basename "$dir")
        echo "| $size_human | $dir_name |"
    done
    echo ""
fi

# ===== IDEs Específicos =====
echo "## IDEs Baseados em VS Code"
echo ""

for ide in Code Cursor Windsurf Antigravity; do
    CONFIG_DIR="$HOME_DIR/.config/$ide"
    if [ -d "$CONFIG_DIR" ]; then
        IDE_SIZE=$(get_size_bytes "$CONFIG_DIR")
        echo "### $ide"
        echo ""
        echo "- **Config:** $(format_size $IDE_SIZE)"

        # Extensões
        case $ide in
            Code) EXT_DIR="$HOME_DIR/.vscode/extensions" ;;
            *) EXT_DIR="$HOME_DIR/.${ide,,}/extensions" ;;
        esac

        if [ -d "$EXT_DIR" ]; then
            EXT_SIZE=$(get_size_bytes "$EXT_DIR")
            EXT_COUNT=$(ls -1 "$EXT_DIR" 2>/dev/null | wc -l)
            echo "- **Extensões:** $(format_size $EXT_SIZE) ($EXT_COUNT extensões)"
        fi

        # Detalhes do cache
        echo "- **Cache interno:**"
        for subdir in Cache CachedData CachedExtensionVSIXs GPUCache logs; do
            if [ -d "$CONFIG_DIR/$subdir" ]; then
                SUB_SIZE=$(get_size_bytes "$CONFIG_DIR/$subdir")
                echo "  - $subdir: $(format_size $SUB_SIZE)"
            fi
        done
        echo ""
    fi
done

# ===== Snap =====
echo "## Snap"
echo ""

if [ -d "$HOME_DIR/snap" ]; then
    SNAP_SIZE=$(get_size_bytes "$HOME_DIR/snap")
    echo "**Tamanho total:** $(format_size $SNAP_SIZE)"
    echo ""
    echo "| Tamanho | Aplicativo |"
    echo "|---------|------------|"
    du -sb "$HOME_DIR/snap"/*/ 2>/dev/null | sort -rn | head -10 | while read size dir; do
        size_human=$(format_size "$size")
        dir_name=$(basename "$dir")
        echo "| $size_human | $dir_name |"
    done
    echo ""

    # Revisões desabilitadas
    if command -v snap &> /dev/null; then
        DISABLED=$(snap list --all 2>/dev/null | grep -c disabled || echo 0)
        echo "**Revisões desabilitadas:** $DISABLED"
        echo ""
    fi
fi

# ===== Docker =====
echo "## Docker"
echo ""

if command -v docker &> /dev/null; then
    echo "**Docker instalado:** Sim"
    echo ""
    echo '```'
    docker system df 2>/dev/null || echo "Não foi possível obter informações do Docker"
    echo '```'
    echo ""

    DOCKER_RAW="$HOME_DIR/.docker/desktop/vms/0/data/Docker.raw"
    if [ -f "$DOCKER_RAW" ]; then
        RAW_SIZE=$(stat -c%s "$DOCKER_RAW" 2>/dev/null || echo 0)
        echo "**Docker.raw (disco virtual):** $(format_size $RAW_SIZE)"
        echo ""
    fi
else
    echo "**Docker instalado:** Não"
    echo ""
fi

# ===== Node.js =====
echo "## Node.js (node_modules)"
echo ""

NODE_TOTAL=0
NODE_COUNT=0

echo "| Tamanho | Última Modificação | Projeto |"
echo "|---------|-------------------|---------|"

find "$HOME_DIR" -maxdepth 5 -name "node_modules" -type d 2>/dev/null | while read dir; do
    size=$(get_size_bytes "$dir")
    size_human=$(format_size "$size")
    parent=$(dirname "$dir")
    parent_name=$(basename "$parent")

    if [ -f "$parent/package.json" ]; then
        mod_date=$(stat -c '%y' "$parent/package.json" 2>/dev/null | cut -d' ' -f1)
    else
        mod_date="N/A"
    fi

    echo "| $size_human | $mod_date | $parent_name |"
done | sort -rh | head -15

echo ""

NODE_TOTAL_SIZE=$(find "$HOME_DIR" -maxdepth 5 -name "node_modules" -type d -exec du -sb {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
NODE_COUNT=$(find "$HOME_DIR" -maxdepth 5 -name "node_modules" -type d 2>/dev/null | wc -l)
echo "**Total node_modules:** $(format_size $NODE_TOTAL_SIZE) em $NODE_COUNT diretórios"
echo ""

# ===== Arquivos por Tipo =====
echo "## Arquivos por Tipo"
echo ""

echo "| Tipo | Tamanho | Quantidade |"
echo "|------|---------|------------|"

# Vídeos
VIDEO_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
VIDEO_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) 2>/dev/null | wc -l)
echo "| Vídeos | $(format_size $VIDEO_SIZE) | $VIDEO_COUNT |"

# Imagens
IMG_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.raw" -o -iname "*.psd" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
IMG_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.raw" -o -iname "*.psd" \) 2>/dev/null | wc -l)
echo "| Imagens | $(format_size $IMG_SIZE) | $IMG_COUNT |"

# Áudio
AUDIO_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
AUDIO_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" \) 2>/dev/null | wc -l)
echo "| Áudio | $(format_size $AUDIO_SIZE) | $AUDIO_COUNT |"

# Documentos
DOC_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.pdf" -o -iname "*.doc*" -o -iname "*.xls*" -o -iname "*.ppt*" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
DOC_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.pdf" -o -iname "*.doc*" -o -iname "*.xls*" -o -iname "*.ppt*" \) 2>/dev/null | wc -l)
echo "| Documentos | $(format_size $DOC_SIZE) | $DOC_COUNT |"

# Arquivos compactados
ZIP_SIZE=$(find "$HOME_DIR" -type f \( -iname "*.zip" -o -iname "*.tar*" -o -iname "*.gz" -o -iname "*.rar" -o -iname "*.7z" \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
ZIP_COUNT=$(find "$HOME_DIR" -type f \( -iname "*.zip" -o -iname "*.tar*" -o -iname "*.gz" -o -iname "*.rar" -o -iname "*.7z" \) 2>/dev/null | wc -l)
echo "| Compactados | $(format_size $ZIP_SIZE) | $ZIP_COUNT |"

echo ""

# ===== Arquivos Grandes =====
echo "## Maiores Arquivos (>200MB)"
echo ""
echo "| Tamanho | Última Modificação | Arquivo |"
echo "|---------|-------------------|---------|"

find "$HOME_DIR" -type f -size +200M 2>/dev/null | \
    xargs -I{} stat --format="%s %Y %n" {} 2>/dev/null | \
    sort -rn | head -20 | while read size mtime filepath; do
        size_human=$(format_size "$size")
        mod_date=$(date -d "@$mtime" +"%Y-%m-%d")
        short_path="${filepath/#$HOME_DIR/~}"
        echo "| $size_human | $mod_date | $short_path |"
done

echo ""

# ===== Arquivos Antigos =====
echo "## Arquivos Antigos (>180 dias sem acesso, >100MB)"
echo ""
echo "| Tamanho | Último Acesso | Arquivo |"
echo "|---------|--------------|---------|"

find "$HOME_DIR" -type f -size +100M -atime +180 2>/dev/null | \
    xargs -I{} stat --format="%s %X %n" {} 2>/dev/null | \
    sort -rn | head -15 | while read size atime filepath; do
        size_human=$(format_size "$size")
        access_date=$(date -d "@$atime" +"%Y-%m-%d")
        short_path="${filepath/#$HOME_DIR/~}"
        echo "| $size_human | $access_date | $short_path |"
done

echo ""

# ===== Lixeira =====
echo "## Lixeira"
echo ""

TRASH_DIR="$HOME_DIR/.local/share/Trash"
if [ -d "$TRASH_DIR" ]; then
    TRASH_SIZE=$(get_size_bytes "$TRASH_DIR")
    TRASH_COUNT=$(find "$TRASH_DIR/files" -maxdepth 1 2>/dev/null | wc -l)
    echo "- **Tamanho:** $(format_size $TRASH_SIZE)"
    echo "- **Itens:** $TRASH_COUNT"
else
    echo "Lixeira vazia ou não encontrada."
fi

echo ""

# ===== Downloads =====
echo "## Downloads"
echo ""

if [ -d "$HOME_DIR/Downloads" ]; then
    DL_SIZE=$(get_size_bytes "$HOME_DIR/Downloads")
    DL_COUNT=$(find "$HOME_DIR/Downloads" -type f 2>/dev/null | wc -l)
    DL_OLD=$(find "$HOME_DIR/Downloads" -type f -mtime +90 2>/dev/null | wc -l)
    echo "- **Tamanho total:** $(format_size "$DL_SIZE")"
    echo "- **Total de arquivos:** $DL_COUNT"
    echo "- **Arquivos >90 dias:** $DL_OLD"
fi

echo ""

# ===== Resumo =====
echo "## Resumo para Análise"
echo ""
echo "Por favor, analise os dados acima e responda:"
echo ""
echo "1. **Prioridade Alta** - O que devo limpar imediatamente?"
echo "2. **Prioridade Média** - O que pode ser limpo com cuidado?"
echo "3. **Manter** - O que definitivamente não devo apagar?"
echo "4. **Backup Primeiro** - O que devo fazer backup antes de limpar?"
echo "5. **Estimativa** - Quanto espaço posso esperar liberar?"
echo ""
echo "---"
echo "*Relatório gerado em $(date '+%Y-%m-%d %H:%M:%S')*"
