# Linux Home Cleanup Toolkit

### Ferramentas profissionais para limpeza e otimização do Linux Ubuntu

[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green?style=flat-square)](https://github.com/johnnyvaz/linux-home-cleanup/commits/main)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](CONTRIBUTING.md)

> **Scripts Bash para liberar espaço em disco, limpar cache de IDEs, Docker, node_modules e otimizar o diretório home no Linux.**

[Guia de Limpeza](docs/GUIA-LIMPEZA.md) | [Problemas do VS Code](docs/PROBLEMAS-VSCODE.md) | [Casos de Uso](docs/CASOS-DE-USO.md) | [Contribuir](CONTRIBUTING.md)

---

## Por que usar este toolkit?

| Problema | Solução |
|----------|---------|
| VS Code consumindo 10GB+ de cache | Script limpa cache de Code, Cursor, Windsurf |
| Docker.raw crescendo infinitamente | Reset seguro do disco virtual Docker |
| node_modules de projetos antigos | Identificação e remoção automática |
| Snaps ocupando espaço duplicado | Remoção de revisões desabilitadas |
| Não sabe onde está o espaço | Análise detalhada com sugestões |

---

## Resultado Real: 165GB Liberados

> *"Eu estava cansado de ver aquela notificação irritante do Ubuntu: **'Espaço em disco insuficiente'**. Aparecia toda semana, sempre no pior momento — no meio de um deploy, compilando um projeto, ou durante uma reunião importante. Eu perdia horas tentando descobrir o que estava consumindo meu SSD de 500GB, deletava alguns arquivos aleatórios, e duas semanas depois... a notificação voltava.*
>
> *Cansei. Decidi investigar a fundo e descobri que o problema não eram meus arquivos — eram caches ocultos de IDEs, Docker inflado, e node_modules de projetos que eu nem lembrava que existiam. Criei estes scripts para resolver de uma vez por todas. Na primeira execução, recuperei **165GB de espaço**. Nunca mais vi aquela notificação."*
>
> **— Johnny, Desenvolvedor Full Stack & Linux Specialist**

### Distribuição do Espaço Recuperado

| Categoria | Espaço | % |
|-----------|--------|---|
| Docker (imagens/volumes/Docker.raw) | 67 GB | 40.6% |
| Caches de IDEs (VS Code, Cursor) | 34 GB | 20.6% |
| node_modules de projetos antigos | 28 GB | 17.0% |
| Cache do sistema (~/.cache) | 19 GB | 11.5% |
| Snaps desabilitados | 12 GB | 7.3% |
| Outros (pip, gradle, thumbnails) | 5 GB | 3.0% |

---

## Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/johnnyvaz/linux-home-cleanup.git
cd linux-home-cleanup

# Dê permissão de execução
chmod +x *.sh scripts/*.sh

# Execute a análise inicial
./analise-espaco.sh
```

### Requisitos

- **Sistema:** Ubuntu 20.04+, Linux Mint, Pop!_OS ou derivados Debian
- **Shell:** Bash 5.0+
- **Ferramentas:** `du`, `find`, `numfmt`, `awk` (pré-instalados)
- **Opcional:** `docker`, `snap`, `npm`, `pip`

---

## Scripts Disponíveis

### 1. Análise de Espaço (`analise-espaco.sh`)

Diagnóstico completo do seu diretório home com relatórios visuais.

```bash
./analise-espaco.sh           # Analisa $HOME
./analise-espaco.sh /caminho  # Analisa diretório específico
```

**O que analisa:**
- Distribuição de espaço por diretório (Top 20)
- Arquivos grandes (>100MB)
- Arquivos por tipo: vídeos, imagens, áudio, documentos
- Arquivos antigos sem acesso (>180 dias)
- Sugestões de otimização e backup

### 2. Limpeza Geral (`limpeza-geral.sh`)

Menu interativo para limpeza segura com confirmações.

```bash
./limpeza-geral.sh           # Menu interativo
./limpeza-geral.sh --all     # Todas as limpezas
./limpeza-geral.sh --vscode  # Apenas cache de IDEs
./limpeza-geral.sh --analyze # Análise de extensões
```

**O que limpa:**
- Cache de VS Code, Cursor, Windsurf, Antigravity
- Cache Python (__pycache__, pip)
- Cache Java/Gradle/JetBrains
- Cache Node.js (npm)
- Sistema (apt, journalctl)
- Docker

### 3. Limpeza Profunda (`limpeza-profunda.sh`)

Para recuperar espaço significativo com operações avançadas.

```bash
./limpeza-profunda.sh
```

**O que limpa:**
- Docker completo (incluindo Docker.raw)
- Snaps desabilitados
- Cache completo (~/.cache)
- APT e logs do sistema

### 4. Análise para IA (`scripts/analise-ia.sh`)

Gera relatório estruturado para análise com ChatGPT, Claude ou Gemini.

```bash
./scripts/analise-ia.sh > relatorio.txt
# Cole no seu assistente de IA para recomendações personalizadas
```

---

## Guia Rápido de Uso

```bash
# Passo 1: Diagnosticar
./analise-espaco.sh

# Passo 2: Limpeza conservadora (primeira vez)
./limpeza-geral.sh

# Passo 3: Limpeza profunda (se precisar mais espaço)
./limpeza-profunda.sh

# Passo 4: Agendar manutenção mensal
echo "0 10 1 * * ~/linux-home-cleanup/analise-espaco.sh" | crontab -
```

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [GUIA-LIMPEZA.md](docs/GUIA-LIMPEZA.md) | Tutorial completo de limpeza passo a passo |
| [PROBLEMAS-VSCODE.md](docs/PROBLEMAS-VSCODE.md) | Por que VS Code consome tanto espaço |
| [CASOS-DE-USO.md](docs/CASOS-DE-USO.md) | 8 cenários reais com soluções |

---

## O Problema do VS Code

IDEs baseados em VS Code são os maiores vilões do consumo de espaço:

```
~/.config/Code/           → 5-15 GB (cache, logs, extensões)
~/.vscode/extensions/     → 1-5 GB (extensões instaladas)
~/snap/code/              → 8-20 GB (se instalado via Snap)
```

**Usando múltiplos IDEs?** Multiplique por 2, 3 ou 4:
- VS Code + Cursor + Windsurf = **30-50GB** de cache!

Veja a documentação completa: [PROBLEMAS-VSCODE.md](docs/PROBLEMAS-VSCODE.md)

---

## Para Mentorados

Este repositório foi criado como material de estudo. Use para:

1. **Aprender Bash** - Estude os scripts e entenda cada comando
2. **Referência rápida** - Consulte quando precisar limpar seu sistema
3. **Base para projetos** - Fork e adapte para suas necessidades

### Exercícios Sugeridos

- [ ] Execute `analise-espaco.sh` e analise o relatório
- [ ] Identifique os 3 maiores consumidores no seu home
- [ ] Use `limpeza-geral.sh` e registre quanto liberou
- [ ] Adicione uma nova funcionalidade via Pull Request

---

## Estrutura do Projeto

```
linux-home-cleanup/
├── analise-espaco.sh         # Análise de espaço
├── limpeza-geral.sh          # Limpeza interativa
├── limpeza-profunda.sh       # Limpeza avançada
├── scripts/
│   └── analise-ia.sh         # Relatório para IA
├── docs/
│   ├── GUIA-LIMPEZA.md       # Guia completo
│   ├── PROBLEMAS-VSCODE.md   # Documentação VS Code
│   └── CASOS-DE-USO.md       # Casos de uso
├── .github/
│   └── ISSUE_TEMPLATE/       # Templates de issues
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── CLAUDE.md
```

---

## Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](CONTRIBUTING.md).

### Como Contribuir

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/minha-feature`
3. Commit suas mudanças: `git commit -m 'feat: adiciona X'`
4. Push: `git push origin feature/minha-feature`
5. Abra um Pull Request

### Compartilhe seu Resultado

Liberou espaço com estes scripts? Abra uma issue contando quanto!

---

## Avisos de Segurança

> **Faça backup** de dados importantes antes de executar limpezas

> **Leia as confirmações** - Os scripts pedem confirmação antes de deletar

> **Docker.raw** - O reset apaga TODAS as imagens e volumes Docker

---

## Licença

[MIT License](LICENSE) - Use, modifique e distribua livremente.

---

## Autor

**Johnny** - Desenvolvedor Full Stack & Linux Specialist

Experiência com sistemas Linux desde 2010. Especialista em automação e otimização de sistemas.

---

## Keywords

`linux` `ubuntu` `bash` `cleanup` `disk-space` `cache` `vscode` `docker` `node-modules` `system-maintenance` `devops` `automation` `shell-script` `home-directory` `storage` `optimization` `snap` `apt` `developer-tools`

---

### Configuração do Repositório GitHub

Após criar o repositório, configure:

**Description:**
```
Scripts Bash para limpeza e otimização do Linux Ubuntu. Libere espaço limpando cache de VS Code, Docker, node_modules e mais. Toolkit completo com análise, limpeza e documentação.
```

**Topics (adicione no GitHub):**
```
linux, ubuntu, bash, cleanup, disk-space, cache-cleaner, vscode, docker,
node-modules, shell-script, devops, automation, system-maintenance,
storage-optimization, developer-tools, linux-mint, pop-os, debian
```

**Website:** Link para a documentação principal ou seu perfil

---

Se este projeto te ajudou, deixe uma estrela!
