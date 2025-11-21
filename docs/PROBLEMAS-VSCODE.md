# Por Que o VS Code Consome Tanto Espaço?

Este documento explica em detalhes por que IDEs baseados em VS Code (incluindo Cursor, Windsurf e Antigravity) consomem tanto espaço em disco e como resolver.

## O Problema

Um desenvolvedor típico pode ter **10GB a 50GB** consumidos apenas por IDEs baseados em VS Code, sem perceber. Isso acontece porque:

1. O VS Code foi projetado para desenvolvedores com SSDs grandes
2. O cache nunca é limpo automaticamente
3. Extensões acumulam dados indefinidamente
4. Múltiplos IDEs fork do VS Code multiplicam o problema

## Anatomia do Consumo de Espaço

### 1. Diretório de Configuração (`~/.config/Code/`)

| Pasta | Descrição | Tamanho Típico |
|-------|-----------|----------------|
| `Cache/` | Cache geral do Electron | 500MB - 2GB |
| `CachedData/` | Bytecode compilado | 200MB - 1GB |
| `CachedExtensionVSIXs/` | Pacotes de extensões baixados | 1GB - 5GB |
| `GPUCache/` | Cache de renderização GPU | 50MB - 200MB |
| `logs/` | Logs de sessões anteriores | 100MB - 500MB |
| `Crashpad/` | Dumps de crash | 50MB - 500MB |
| `User/workspaceStorage/` | Dados por projeto | 500MB - 10GB |

### 2. Diretório de Extensões (`~/.vscode/extensions/`)

Cada extensão pode consumir de 10MB a 500MB. Um desenvolvedor full-stack típico tem 30-50 extensões.

**Problemas comuns:**

- **Versões duplicadas**: Ao atualizar, versões antigas nem sempre são removidas
- **Extensões abandonadas**: Extensões que você testou e esqueceu
- **Extensões pesadas**: Algumas extensões incluem binários grandes

**Extensões notoriamente grandes:**

| Extensão | Tamanho Aproximado |
|----------|-------------------|
| ms-python.python | 150MB+ |
| ms-vscode.cpptools | 200MB+ |
| golang.go | 100MB+ |
| rust-analyzer | 150MB+ |
| GitHub Copilot | 100MB+ |

### 3. workspaceStorage - O Vilão Oculto

Localizado em `~/.config/Code/User/workspaceStorage/`, este diretório contém:

- Estado de extensões por projeto
- Cache de IntelliSense
- Histórico de arquivos
- Configurações de debug

**O problema**: Cada projeto que você abre cria uma pasta aqui. Projetos deletados deixam pastas órfãs.

```bash
# Ver tamanho do workspaceStorage
du -sh ~/.config/Code/User/workspaceStorage/

# Resultado comum: 5-15GB em sistemas antigos!
```

### 4. VS Code via Snap - Problema Dobrado

Se você instalou VS Code via Snap, o problema é ainda pior:

```bash
# Estrutura do Snap
~/snap/code/
├── common/          # Dados compartilhados entre versões
├── current/         # Link para versão atual
├── 123/             # Revisão antiga (não removida!)
├── 124/             # Revisão antiga
└── 125/             # Versão atual
```

Cada revisão do Snap mantém uma cópia completa dos dados do usuário. O Snap mantém 3 revisões por padrão.

**Espaço típico do VS Code Snap: 8-15GB**

## Múltiplos IDEs = Problema Multiplicado

Se você usa mais de um IDE baseado em VS Code:

| IDE | Config | Extensões | Cache Sistema |
|-----|--------|-----------|---------------|
| VS Code | `~/.config/Code/` | `~/.vscode/` | `~/.cache/vscode-*` |
| Cursor | `~/.config/Cursor/` | `~/.cursor/` | `~/.cache/cursor-*` |
| Windsurf | `~/.config/Windsurf/` | `~/.windsurf/` | - |
| Antigravity | `~/.config/Antigravity/` | `~/.antigravity/` | - |

**4 IDEs = 4x o consumo de espaço!**

## Soluções

### Limpeza Imediata (Segura)

Use o script `limpeza-geral.sh`:

```bash
./limpeza-geral.sh --vscode
```

Isso limpa apenas caches, mantendo suas configurações e extensões.

### Limpeza de workspaceStorage

```bash
# Listar projetos órfãos (pasta do projeto não existe mais)
for dir in ~/.config/Code/User/workspaceStorage/*/; do
    ws_file="$dir/workspace.json"
    if [ -f "$ws_file" ]; then
        folder=$(grep -o '"folder":"[^"]*"' "$ws_file" | cut -d'"' -f4 | sed 's|file://||')
        if [ ! -d "$folder" ]; then
            echo "Órfão: $dir -> $folder"
        fi
    fi
done
```

### Limpeza de Extensões Duplicadas

```bash
# Listar extensões com múltiplas versões
ls -1 ~/.vscode/extensions/ | \
    sed 's/-[0-9]*\.[0-9]*\.[0-9]*$//' | \
    sort | uniq -d
```

### Migrar do Snap para .deb

Se você usa o Snap do VS Code, considere migrar:

```bash
# Backup das configurações
cp -r ~/.config/Code ~/.config/Code.backup

# Remover Snap
sudo snap remove code

# Instalar via .deb (download do site oficial)
# https://code.visualstudio.com/download

# Restaurar configurações (o .deb usa o mesmo diretório)
```

**Economia esperada: 3-8GB**

## Prevenção

### 1. Limpeza Mensal

Adicione ao cron:

```bash
# Limpar cache do VS Code todo mês
0 10 1 * * rm -rf ~/.config/Code/Cache/* ~/.config/Code/CachedData/*
```

### 2. Configurar Retenção de Logs

No `settings.json`:

```json
{
    "files.maxMemoryForLargeFilesMB": 1024,
    "extensions.autoUpdate": true,
    "extensions.autoCheckUpdates": true
}
```

### 3. Revisar Extensões Regularmente

- Desinstale extensões que não usa
- Use perfis do VS Code para separar extensões por tipo de projeto
- Prefira extensões leves

### 4. Limitar Snap Revisions

```bash
# Manter apenas 2 revisões de snaps
sudo snap set system refresh.retain=2
```

## Quanto Espaço Você Pode Recuperar?

| Cenário | Economia Esperada |
|---------|-------------------|
| Desenvolvedor casual (1 IDE, 20 extensões) | 2-5 GB |
| Desenvolvedor full-stack (2 IDEs, 40 extensões) | 5-15 GB |
| Power user (4 IDEs, 60+ extensões, Snap) | 15-40 GB |

## Verificando Seu Sistema

Execute para ver o estado atual:

```bash
echo "=== VS Code ==="
du -sh ~/.config/Code/ 2>/dev/null
du -sh ~/.vscode/ 2>/dev/null
du -sh ~/snap/code/ 2>/dev/null

echo "=== Cursor ==="
du -sh ~/.config/Cursor/ 2>/dev/null
du -sh ~/.cursor/ 2>/dev/null

echo "=== Windsurf ==="
du -sh ~/.config/Windsurf/ 2>/dev/null
du -sh ~/.windsurf/ 2>/dev/null

echo "=== Total Cache Sistema ==="
du -sh ~/.cache/vscode* 2>/dev/null
```

## Conclusão

O VS Code é uma ferramenta excelente, mas seu modelo de cache agressivo combinado com a proliferação de forks significa que desenvolvedores precisam fazer manutenção ativa do espaço em disco.

Use os scripts deste repositório para automatizar essa manutenção e recuperar dezenas de gigabytes do seu sistema.
