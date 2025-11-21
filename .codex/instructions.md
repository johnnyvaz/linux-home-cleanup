# Codex CLI Instructions

## Project

Linux Home Cleanup Toolkit - Bash scripts for disk cleanup and optimization on Ubuntu Linux.

## Key Files

- `analise-espaco.sh` - Disk space analysis
- `limpeza-geral.sh` - Interactive cleanup menu
- `limpeza-profunda.sh` - Deep system cleanup
- `scripts/analise-ia.sh` - AI report generator

## Coding Standards

- Use `set -euo pipefail` in all scripts
- Always confirm before deleting files
- Use color variables: RED, GREEN, YELLOW, BLUE, CYAN, NC
- Format sizes with `format_size()` function
- Comments in Portuguese (Brazilian audience)
- 4-space indentation

## Common Patterns

```bash
# Size check pattern
if [ "$size" -gt 1073741824 ]; then  # > 1GB
    # do something
fi

# Safe deletion pattern
if prompt_confirmation "Delete?"; then
    rm -rf "$dir"/* 2>/dev/null || true
fi
```

## Size Constants (bytes)

- 100MB = 104857600
- 500MB = 536870912
- 1GB = 1073741824
- 5GB = 5368709120

## Do Not

- Delete without user confirmation
- Use hardcoded absolute paths
- Add external dependencies
- Write documentation in English (except agent configs)

See AGENTS.md for complete guidelines.
