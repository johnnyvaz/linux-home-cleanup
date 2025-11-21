# Gemini CLI Instructions

## Project Overview

**Linux Home Cleanup Toolkit** - Professional Bash scripts for cleaning, analyzing, and optimizing the home directory on Linux Ubuntu.

## Repository Structure

```
├── analise-espaco.sh      # Space analysis with visual reports
├── limpeza-geral.sh       # Interactive cleanup (menu-driven)
├── limpeza-profunda.sh    # Deep cleanup (requires sudo)
├── scripts/analise-ia.sh  # Generate AI-friendly reports
├── docs/                  # Documentation in Portuguese
```

## Coding Conventions

### Required in All Scripts

```bash
#!/bin/bash
set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
```

### Helper Functions Available

- `format_size($bytes)` - Convert bytes to human readable
- `get_dir_size($path)` - Get directory size in bytes
- `prompt_confirmation($message)` - Ask yes/no question
- `header($title)` - Print section header
- `clean_directory($path, $description)` - Safe directory cleanup

### Size Thresholds

| Size | Bytes |
|------|-------|
| 100MB | 104857600 |
| 500MB | 536870912 |
| 1GB | 1073741824 |
| 5GB | 5368709120 |

## Rules

### Must Do

- Confirm before any deletion
- Use `$HOME` instead of hardcoded paths
- Handle errors with `2>/dev/null || true`
- Quote all variables: `"$var"`
- Write comments in Portuguese

### Must Not

- Delete without confirmation
- Add external dependencies
- Change directory structure arbitrarily
- Write user-facing docs in English

## Target Systems

- Ubuntu 20.04+
- Linux Mint
- Pop!_OS
- Debian-based distributions

## Full Documentation

See `AGENTS.md` for complete agent guidelines.
