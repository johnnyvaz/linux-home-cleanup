# Contribuindo para o Linux Home Cleanup Toolkit

Obrigado pelo interesse em contribuir! Este guia vai te ajudar a fazer contribuições de qualidade.

## Como Contribuir

### Reportando Bugs

1. Verifique se o bug já não foi reportado nas [Issues](../../issues)
2. Se não encontrar, crie uma nova issue com:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs. atual
   - Versão do Ubuntu e Bash
   - Output relevante (sem dados sensíveis!)

### Sugerindo Melhorias

1. Abra uma issue com a tag `enhancement`
2. Descreva a melhoria e por que seria útil
3. Se possível, inclua exemplos de uso

### Enviando Pull Requests

1. Fork o repositório
2. Crie uma branch para sua feature: `git checkout -b feature/minha-feature`
3. Faça commits atômicos com mensagens claras
4. Teste suas alterações em um ambiente real
5. Envie o PR com descrição detalhada

## Padrões de Código

### Estrutura dos Scripts

```bash
#!/bin/bash
#
# nome-do-script.sh - Descrição breve
# Autor: Seu Nome
# Data: YYYY-MM-DD
#
# Descrição detalhada do que o script faz
#

set -euo pipefail

# ===== Cores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===== Funções Auxiliares =====
# ... funções aqui ...

# ===== Main =====
main() {
    # lógica principal
}

main "$@"
```

### Convenções

- **Indentação**: 4 espaços (não tabs)
- **Nomes de variáveis**: UPPER_CASE para constantes, lower_case para locais
- **Nomes de funções**: snake_case
- **Comentários**: Em português, claros e concisos
- **Cores**: Use as variáveis definidas, não códigos ANSI diretos

### Boas Práticas

```bash
# SEMPRE use set -euo pipefail
set -euo pipefail

# SEMPRE peça confirmação antes de deletar
if prompt_confirmation "Deseja continuar?"; then
    rm -rf "$diretorio"
fi

# SEMPRE use aspas em variáveis
echo "$variavel"  # correto
echo $variavel    # incorreto

# SEMPRE trate erros em comandos que podem falhar
comando 2>/dev/null || true

# SEMPRE formate tamanhos para humanos
format_size "$bytes"  # retorna "1.5GiB"
```

### Segurança

- **NUNCA** delete arquivos sem confirmação do usuário
- **NUNCA** use `rm -rf /` ou caminhos absolutos perigosos
- **SEMPRE** valide inputs do usuário
- **SEMPRE** use caminhos relativos ao `$HOME` quando possível
- **SEMPRE** mostre o que será deletado ANTES de deletar

## Estrutura de Diretórios

```
linux-home-cleanup/
├── *.sh                 # Scripts principais (raiz)
├── scripts/             # Scripts auxiliares
├── docs/                # Documentação
└── assets/              # Imagens e recursos
```

## Testando

Antes de enviar um PR:

1. Teste em uma VM ou sistema de teste
2. Execute com diferentes cenários:
   - Home limpo (recém-instalado)
   - Home cheio (uso real)
   - Sem Docker instalado
   - Sem Snap instalado
3. Verifique se não há erros de sintaxe: `bash -n script.sh`
4. Verifique com shellcheck: `shellcheck script.sh`

## Documentação

- Atualize o README.md se adicionar features
- Documente novos scripts nos docs/
- Use português claro e acessível
- Inclua exemplos de uso

## Commits

### Formato

```
tipo: descrição curta

Descrição mais detalhada se necessário.
```

### Tipos

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Apenas documentação
- `style`: Formatação (não afeta lógica)
- `refactor`: Refatoração de código
- `test`: Adição de testes
- `chore`: Manutenção geral

### Exemplos

```
feat: adiciona limpeza de cache do Spotify

fix: corrige detecção de Docker não instalado

docs: atualiza guia de limpeza com seção de Flatpak
```

## Código de Conduta

- Seja respeitoso e inclusivo
- Aceite críticas construtivas
- Foque no que é melhor para a comunidade
- Ajude outros contribuidores

## Dúvidas?

Abra uma issue com a tag `question` ou entre em contato.

---

**Obrigado por contribuir!**
