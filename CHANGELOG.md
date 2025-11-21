# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2025-11-21

### Adicionado

- **analise-espaco.sh**: Script de análise completa do diretório home
  - Distribuição de espaço por diretório (Top 20)
  - Identificação de arquivos grandes (>100MB)
  - Análise por tipo de arquivo (vídeos, imagens, áudio, documentos)
  - Detecção de arquivos antigos sem acesso (>180 dias)
  - Sugestões de otimização e backup
  - Geração de relatórios em arquivo

- **limpeza-geral.sh**: Script de limpeza interativa com menu
  - Limpeza de cache de IDEs (VS Code, Cursor, Windsurf, Antigravity)
  - Limpeza de cache Python (__pycache__, pip)
  - Limpeza de cache Java/Gradle/JetBrains
  - Limpeza de cache Node.js (npm)
  - Limpeza do sistema (apt, journalctl)
  - Limpeza Docker
  - Análise de extensões antigas
  - Flags: `--all`, `--vscode`, `--analyze`

- **limpeza-profunda.sh**: Script de limpeza avançada
  - Reset completo do Docker (incluindo Docker.raw)
  - Remoção de snaps desabilitados
  - Limpeza completa do ~/.cache
  - Limpeza de APT e logs do sistema

- **scripts/analise-ia.sh**: Gerador de relatório para IA
  - Formato markdown estruturado
  - Compatível com ChatGPT, Claude, Gemini
  - Análise detalhada para recomendações personalizadas

- **Documentação completa**
  - README.md com testemunho real (165GB liberados)
  - docs/GUIA-LIMPEZA.md - Tutorial completo
  - docs/PROBLEMAS-VSCODE.md - Documentação sobre consumo de espaço do VS Code
  - docs/CASOS-DE-USO.md - 8 cenários reais com soluções

- **Configuração para agentes de IA**
  - AGENTS.md - Instruções unificadas
  - CLAUDE.md - Configuração para Claude Code
  - .codex/ - Configuração para OpenAI Codex CLI
  - .gemini/ - Configuração para Google Gemini CLI

- **Infraestrutura GitHub**
  - Templates de issues (bug, feature, resultados)
  - Template de Pull Request
  - Configuração de funding
  - GitHub Actions para validação

- **install.sh**: Script de instalação automatizada

### Segurança

- Todos os scripts pedem confirmação antes de operações destrutivas
- Uso de `set -euo pipefail` para tratamento rigoroso de erros
- Sem dependências externas além de ferramentas padrão do sistema

---

## Tipos de Mudanças

- **Adicionado** para novas funcionalidades
- **Modificado** para mudanças em funcionalidades existentes
- **Descontinuado** para funcionalidades que serão removidas
- **Removido** para funcionalidades removidas
- **Corrigido** para correções de bugs
- **Segurança** para correções de vulnerabilidades
