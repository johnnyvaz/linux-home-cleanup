# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Linux Home Cleanup Toolkit - Professional collection of Bash scripts for Linux system maintenance, disk space analysis, and home directory optimization. Designed as a reference repository and learning resource.

## Repository Structure

```
linux-home-cleanup/
├── analise-espaco.sh         # Disk space analysis
├── limpeza-geral.sh          # General cleanup (interactive menu)
├── limpeza-profunda.sh       # Deep system cleanup
├── scripts/
│   └── analise-ia.sh         # AI-friendly report generator
├── docs/
│   ├── GUIA-LIMPEZA.md       # Complete cleanup guide
│   ├── PROBLEMAS-VSCODE.md   # VS Code space issues documentation
│   └── CASOS-DE-USO.md       # Real-world use cases
├── README.md                 # Project overview with testimonial
├── CONTRIBUTING.md           # Contribution guidelines
└── LICENSE                   # MIT License
```

## Scripts

### analise-espaco.sh
Disk space analysis tool that scans `$HOME` and generates reports:
- Directory size distribution (Top 20)
- Large files (>100MB)
- File type breakdown (videos, images, audio, documents, archives)
- Development artifacts (node_modules, .git)
- Old/unused files (>180 days without access)
- Optimization suggestions (compression, cloud backup, cleanup)

```bash
./analise-espaco.sh [directory]  # defaults to $HOME
```

Reports saved to `$HOME/Documentos/limpeza/reports/`

### limpeza-geral.sh
Unified cleanup script with interactive menu:
- VS Code-based IDEs cache (Code, Cursor, Windsurf, Antigravity)
- Python cache (__pycache__, pip)
- Java/Gradle/JetBrains cache
- Node.js cache (npm)
- System cleanup (apt, journalctl)
- Docker cleanup
- IDE extension analysis

```bash
./limpeza-geral.sh           # interactive menu
./limpeza-geral.sh --all     # run all cleanups
./limpeza-geral.sh --vscode  # only IDE cache
./limpeza-geral.sh --analyze # only extension analysis
```

### limpeza-profunda.sh
Deep system cleanup with sudo operations:
- Docker (including Docker.raw disk image reset)
- Snap revisions (removes disabled/old versions)
- ~/.cache cleanup (uv, Brave, Puppeteer, Playwright, yarn, pnpm, JetBrains, etc.)
- APT cache and journalctl logs

```bash
./limpeza-profunda.sh  # interactive with confirmations
```

### scripts/analise-ia.sh
Generates structured markdown report optimized for AI analysis (ChatGPT, Claude, Gemini):

```bash
./scripts/analise-ia.sh > relatorio.txt
# Paste content in AI assistant for personalized cleanup recommendations
```

## Code Conventions

- All scripts use `set -euo pipefail` for strict error handling
- Colored output via ANSI escape codes (RED, GREEN, YELLOW, BLUE, CYAN, MAGENTA, BOLD, NC)
- Common helper functions:
  - `format_size()` - numfmt wrapper for human-readable sizes
  - `get_dir_size()` - returns directory size in bytes
  - `prompt_confirmation()` - interactive yes/no prompt
  - `header()` / `subheader()` - formatted section titles
- User confirmations required before destructive operations
- Size thresholds in bytes (e.g., 1073741824 = 1GB, 536870912 = 500MB)

## Documentation Language

All documentation is in Brazilian Portuguese (pt-BR) as this is a reference for mentees.

## Key Technical Details

- Scripts target Ubuntu 20.04+ and derivatives
- Supports multiple VS Code forks: Code, Cursor, Windsurf, Antigravity
- Docker cleanup includes Docker Desktop's Docker.raw virtual disk
- Snap cleanup respects revision retention settings
