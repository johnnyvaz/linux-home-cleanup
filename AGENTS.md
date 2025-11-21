# AGENTS.md

Instruções unificadas para agentes de IA (Claude Code, Codex CLI, Gemini CLI) trabalhando neste repositório.

## Sobre o Projeto

**Linux Home Cleanup Toolkit** - Scripts Bash profissionais para limpeza, análise e otimização do diretório home no Linux Ubuntu.

### Objetivo

Ajudar desenvolvedores a recuperar espaço em disco identificando e limpando:
- Cache de IDEs (VS Code, Cursor, Windsurf, Antigravity)
- Docker (imagens, volumes, Docker.raw)
- node_modules de projetos antigos
- Cache do sistema (~/.cache)
- Snaps desabilitados
- Logs e arquivos temporários

### Público-Alvo

- Desenvolvedores Linux
- Mentorados aprendendo Bash
- Usuários Ubuntu/Debian com problemas de espaço

## Estrutura do Repositório

```
linux-home-cleanup/
├── analise-espaco.sh         # Análise completa do home
├── limpeza-geral.sh          # Limpeza interativa com menu
├── limpeza-profunda.sh       # Limpeza avançada (sudo)
├── scripts/
│   └── analise-ia.sh         # Gerador de relatório para IA
├── docs/
│   ├── GUIA-LIMPEZA.md       # Tutorial completo
│   ├── PROBLEMAS-VSCODE.md   # Documentação VS Code
│   └── CASOS-DE-USO.md       # Cenários reais
├── .github/                  # Templates e configs GitHub
├── README.md                 # Documentação principal
├── CONTRIBUTING.md           # Guia de contribuição
├── LICENSE                   # MIT
└── AGENTS.md                 # Este arquivo
```

## Convenções de Código

### Estrutura de Scripts Bash

```bash
#!/bin/bash
#
# nome-do-script.sh - Descrição breve
# Autor: Johnny
# Data: YYYY-MM-DD
#

set -euo pipefail

# ===== Cores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===== Funções =====

# ===== Main =====
main() {
    # ...
}

main "$@"
```

### Padrões Obrigatórios

1. **Sempre use** `set -euo pipefail` no início
2. **Sempre peça confirmação** antes de deletar arquivos
3. **Use variáveis de cor** definidas, não códigos ANSI diretos
4. **Formate tamanhos** com `format_size()` (wrapper do numfmt)
5. **Comente em português** - projeto voltado para brasileiros
6. **Indentação**: 4 espaços (não tabs)

### Funções Utilitárias Disponíveis

```bash
# Formatar bytes para humano (1073741824 → "1.0GiB")
format_size "$bytes"

# Obter tamanho de diretório em bytes
get_dir_size "/caminho/diretorio"

# Pedir confirmação do usuário
if prompt_confirmation "Deseja continuar?"; then
    # usuário confirmou
fi

# Cabeçalho de seção
header "TÍTULO DA SEÇÃO"
subheader "Subtítulo"
```

### Thresholds de Tamanho (em bytes)

```bash
# Referência rápida
100MB  = 104857600
500MB  = 536870912
1GB    = 1073741824
5GB    = 5368709120
10GB   = 10737418240
```

## Regras para Agentes

### DO (Faça)

- Mantenha compatibilidade com Ubuntu 20.04+
- Teste comandos com `2>/dev/null || true` quando podem falhar
- Use `"$variavel"` sempre (com aspas)
- Adicione novos scripts na raiz ou em `scripts/`
- Documente novas features em `docs/`
- Siga o padrão de cores existente

### DON'T (Não Faça)

- Não delete arquivos sem confirmação do usuário
- Não use caminhos absolutos hardcoded (use `$HOME`)
- Não adicione dependências externas sem necessidade
- Não mude a estrutura de diretórios sem motivo
- Não escreva em inglês na documentação (exceto AGENTS.md)

## Tarefas Comuns

### Adicionar Nova Limpeza

1. Identifique o diretório/arquivo alvo
2. Adicione função em `limpeza-geral.sh` ou `limpeza-profunda.sh`
3. Use o padrão:

```bash
clean_novo_item() {
    local dir="$HOME/.cache/novo-item"
    if [ -d "$dir" ]; then
        local size=$(get_dir_size "$dir")
        if [ "$size" -gt 104857600 ]; then  # > 100MB
            echo -e "${YELLOW}Cache do Novo Item: $(format_size $size)${NC}"
            if prompt_confirmation "Limpar cache do Novo Item?"; then
                rm -rf "$dir"/*
                echo -e "${GREEN}Cache limpo!${NC}"
            fi
        fi
    fi
}
```

### Adicionar Nova Análise

1. Adicione seção em `analise-espaco.sh`
2. Use o padrão de header/subheader
3. Mostre tamanho formatado e contagem

### Atualizar Documentação

- README.md: Apenas para features principais
- docs/GUIA-LIMPEZA.md: Instruções detalhadas
- docs/CASOS-DE-USO.md: Novos cenários

## Contexto Técnico

### IDEs Suportados

| IDE | Config | Extensões |
|-----|--------|-----------|
| VS Code | `~/.config/Code/` | `~/.vscode/extensions/` |
| Cursor | `~/.config/Cursor/` | `~/.cursor/extensions/` |
| Windsurf | `~/.config/Windsurf/` | `~/.windsurf/extensions/` |
| Antigravity | `~/.config/Antigravity/` | `~/.antigravity/extensions/` |

### Caches Conhecidos

```
~/.cache/                    # Cache geral do sistema
~/.cache/pip/                # Python pip
~/.cache/npm/                # Node.js npm
~/.cache/yarn/               # Yarn
~/.cache/pnpm/               # pnpm
~/.cache/uv/                 # Python uv
~/.cache/JetBrains/          # IDEs JetBrains
~/.cache/BraveSoftware/      # Brave Browser
~/.cache/google-chrome/      # Chrome
~/.cache/mozilla/            # Firefox
~/.cache/thumbnails/         # Miniaturas do sistema
~/.cache/puppeteer/          # Puppeteer browsers
~/.cache/ms-playwright/      # Playwright browsers
```

### Docker

- Imagens: `docker images`
- Containers: `docker ps -a`
- Volumes: `docker volume ls`
- Disco virtual: `~/.docker/desktop/vms/0/data/Docker.raw`

## Links Úteis

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - Linter para Bash
- [Ubuntu Package Search](https://packages.ubuntu.com/)
