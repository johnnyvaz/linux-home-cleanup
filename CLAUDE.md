# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note:** For complete agent guidelines, see [AGENTS.md](AGENTS.md). This file is kept for Claude Code compatibility.

## Project Overview

Linux Home Cleanup Toolkit - Professional collection of Bash scripts for Linux system maintenance, disk space analysis, and home directory optimization. Designed as a reference repository and learning resource for mentees.

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
├── .codex/                   # OpenAI Codex CLI config
│   └── instructions.md
├── .gemini/                  # Google Gemini CLI config
│   ├── instructions.md
│   └── settings.json
├── .github/                  # GitHub templates
├── AGENTS.md                 # Unified agent instructions
├── CLAUDE.md                 # This file (Claude Code)
├── README.md                 # Project overview
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

### limpeza-geral.sh
Unified cleanup script with interactive menu:
- VS Code-based IDEs cache (Code, Cursor, Windsurf, Antigravity)
- Python cache (__pycache__, pip)
- Java/Gradle/JetBrains cache
- Node.js cache (npm)
- System cleanup (apt, journalctl)
- Docker cleanup

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
Generates structured markdown report for AI analysis:

```bash
./scripts/analise-ia.sh > relatorio.txt
```

## Code Conventions

### Required Standards

```bash
#!/bin/bash
set -euo pipefail  # Always use strict mode

# Color variables (use these, not raw ANSI codes)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
```

### Helper Functions

- `format_size($bytes)` - Convert bytes to human readable (1GB → "1.0GiB")
- `get_dir_size($path)` - Get directory size in bytes
- `prompt_confirmation($msg)` - Interactive yes/no prompt
- `header($title)` / `subheader($title)` - Formatted section headers
- `clean_directory($path, $desc)` - Safe cleanup with size tracking

### Size Thresholds (bytes)

```bash
100MB  = 104857600
500MB  = 536870912
1GB    = 1073741824
5GB    = 5368709120
10GB   = 10737418240
```

## Rules

### DO

- Always confirm before deleting files
- Use `$HOME` instead of hardcoded paths
- Handle errors: `command 2>/dev/null || true`
- Quote variables: `"$var"`
- Comment in Portuguese (target audience)
- Test on Ubuntu 20.04+

### DON'T

- Delete without user confirmation
- Add external dependencies unnecessarily
- Write user docs in English
- Use tabs (use 4 spaces)

## Technical Context

### Supported IDEs

| IDE | Config | Extensions |
|-----|--------|------------|
| VS Code | `~/.config/Code/` | `~/.vscode/extensions/` |
| Cursor | `~/.config/Cursor/` | `~/.cursor/extensions/` |
| Windsurf | `~/.config/Windsurf/` | `~/.windsurf/extensions/` |
| Antigravity | `~/.config/Antigravity/` | `~/.antigravity/extensions/` |

### Target Systems

- Ubuntu 20.04+
- Linux Mint
- Pop!_OS
- Debian-based distributions
