# Guia Completo de Limpeza do Home no Linux

Este guia ensina a diagnosticar, limpar e manter seu diretório home organizado e otimizado.

## Índice

1. [Diagnóstico Inicial](#1-diagnóstico-inicial)
2. [Limpeza por Categoria](#2-limpeza-por-categoria)
3. [Limpeza Profunda](#3-limpeza-profunda)
4. [Manutenção Preventiva](#4-manutenção-preventiva)
5. [Backup Antes de Limpar](#5-backup-antes-de-limpar)

---

## 1. Diagnóstico Inicial

Antes de limpar, entenda onde está seu espaço.

### Visão Geral do Sistema

```bash
# Espaço total no disco
df -h /home

# Tamanho do seu home
du -sh ~

# Top 10 pastas no home
du -sh ~/*/ 2>/dev/null | sort -rh | head -10
```

### Usando o Script de Análise

```bash
./analise-espaco.sh
```

Este script gera um relatório completo com:
- Distribuição por diretório
- Arquivos grandes (>100MB)
- Análise por tipo de arquivo
- Arquivos antigos sem acesso
- Sugestões de otimização

### Principais Suspeitos

| Diretório | O que contém | Tamanho típico |
|-----------|--------------|----------------|
| `~/.cache` | Caches de aplicativos | 5-20 GB |
| `~/.local/share` | Dados de aplicativos | 2-10 GB |
| `~/.config` | Configurações (inclui cache de IDEs) | 5-30 GB |
| `~/snap` | Dados de aplicativos Snap | 5-20 GB |
| `~/.docker` | Docker Desktop (Docker.raw) | 20-100 GB |
| `~/Downloads` | Downloads esquecidos | 5-50 GB |
| Projetos | node_modules, vendor, target | 10-100 GB |

---

## 2. Limpeza por Categoria

### 2.1 Cache do Sistema (~/.cache)

**Seguro para limpar:** O cache é recriado automaticamente.

```bash
# Ver tamanho total
du -sh ~/.cache

# Maiores consumidores
du -sh ~/.cache/*/ 2>/dev/null | sort -rh | head -15

# Limpeza completa (cuidado!)
rm -rf ~/.cache/*

# Limpeza seletiva (recomendado)
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.cache/pip/*
rm -rf ~/.cache/npm/*
rm -rf ~/.cache/yarn/*
```

### 2.2 IDEs e Editores

#### VS Code e Forks

```bash
# Cache do VS Code
rm -rf ~/.config/Code/Cache/*
rm -rf ~/.config/Code/CachedData/*
rm -rf ~/.config/Code/CachedExtensionVSIXs/*
rm -rf ~/.config/Code/GPUCache/*
rm -rf ~/.config/Code/logs/*

# Para Cursor
rm -rf ~/.config/Cursor/Cache/*
rm -rf ~/.config/Cursor/CachedData/*
# ... mesmo padrão

# Ou use o script
./limpeza-geral.sh --vscode
```

#### JetBrains (IntelliJ, PyCharm, WebStorm)

```bash
rm -rf ~/.cache/JetBrains/*
rm -rf ~/.local/share/JetBrains/*
```

### 2.3 Linguagens de Programação

#### Node.js

```bash
# Cache do npm
npm cache clean --force
rm -rf ~/.npm/_cacache

# Cache do yarn
yarn cache clean
rm -rf ~/.cache/yarn

# Cache do pnpm
pnpm store prune

# node_modules antigos (projetos não modificados há 90+ dias)
find ~/projetos -name "node_modules" -type d -mtime +90 -exec rm -rf {} +
```

#### Python

```bash
# Cache do pip
pip cache purge
rm -rf ~/.cache/pip

# __pycache__ em todo o sistema
find ~ -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

# Arquivos .pyc
find ~ -type f -name "*.pyc" -delete 2>/dev/null

# Cache do uv (gerenciador moderno)
rm -rf ~/.cache/uv
```

#### Java/Kotlin

```bash
# Maven
rm -rf ~/.m2/repository

# Gradle
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/wrapper/dists
```

#### Rust

```bash
# Limpar builds antigos
cargo clean --all

# Cache do registry
rm -rf ~/.cargo/registry/cache
```

#### Go

```bash
# Cache de módulos
go clean -modcache

# Cache de build
go clean -cache
```

### 2.4 Docker

O Docker é um dos maiores consumidores de espaço.

```bash
# Ver uso atual
docker system df

# Limpeza básica (containers parados, imagens não usadas)
docker system prune -f

# Limpeza completa (incluindo volumes)
docker system prune -af --volumes

# Ver tamanho do Docker.raw (Docker Desktop)
ls -lh ~/.docker/desktop/vms/0/data/Docker.raw
```

**Sobre o Docker.raw:**
- É um disco virtual que só cresce, nunca diminui automaticamente
- Para reduzir: Settings > Resources > Virtual disk limit

### 2.5 Snap

```bash
# Ver revisões antigas
snap list --all | awk '/disabled/{print $1, $3}'

# Remover revisões desabilitadas
snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
    sudo snap remove "$snapname" --revision="$revision"
done

# Limitar a 2 revisões
sudo snap set system refresh.retain=2
```

### 2.6 Flatpak

```bash
# Remover runtimes não utilizados
flatpak uninstall --unused

# Limpar cache
rm -rf ~/.var/app/*/cache/*
```

### 2.7 Navegadores

```bash
# Chrome
rm -rf ~/.cache/google-chrome/Default/Cache/*
rm -rf ~/.cache/google-chrome/Default/Code\ Cache/*

# Firefox
rm -rf ~/.cache/mozilla/firefox/*.default*/cache2/*

# Brave
rm -rf ~/.cache/BraveSoftware/Brave-Browser/Default/Cache/*
```

### 2.8 Downloads e Lixeira

```bash
# Downloads antigos (>90 dias)
find ~/Downloads -type f -mtime +90 -delete

# Esvaziar lixeira
rm -rf ~/.local/share/Trash/*
```

---

## 3. Limpeza Profunda

Para situações onde você precisa de muito espaço rapidamente.

### Usando o Script

```bash
./limpeza-profunda.sh
```

### Procedimento Manual

```bash
# 1. Identificar maiores arquivos
find ~ -type f -size +500M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh

# 2. Identificar diretórios com muitos arquivos
find ~ -type d -exec sh -c 'echo "$(find "$1" -maxdepth 1 -type f | wc -l) $1"' _ {} \; 2>/dev/null | sort -rn | head -20

# 3. Arquivos não acessados há mais de 1 ano
find ~ -type f -atime +365 -size +100M -exec ls -lh {} \; 2>/dev/null

# 4. Arquivos duplicados (usando fdupes)
sudo apt install fdupes
fdupes -r ~ --size
```

---

## 4. Manutenção Preventiva

### Cron Jobs Recomendados

```bash
# Editar crontab
crontab -e

# Adicionar:
# Limpar cache de thumbnails semanalmente
0 3 * * 0 rm -rf ~/.cache/thumbnails/*

# Limpar logs de IDEs mensalmente
0 4 1 * * rm -rf ~/.config/Code/logs/* ~/.config/Cursor/logs/*

# Análise mensal de espaço
0 10 1 * * ~/linux-home-cleanup/analise-espaco.sh > /dev/null
```

### Script de Manutenção Semanal

```bash
#!/bin/bash
# manutencao-semanal.sh

# Limpar caches temporários
rm -rf ~/.cache/thumbnails/*
rm -rf /tmp/* 2>/dev/null

# Limpar logs antigos
find ~/.config -name "*.log" -mtime +30 -delete 2>/dev/null

# Mostrar resumo
echo "Espaço disponível:"
df -h /home | tail -1
```

---

## 5. Backup Antes de Limpar

### O Que Fazer Backup

**Importante (sempre backup):**
- `~/.ssh/` - Chaves SSH
- `~/.gnupg/` - Chaves GPG
- `~/.config/` - Configurações de aplicativos (seletivo)
- Seus projetos e documentos

**Opcional (pode recriar):**
- `~/.bashrc`, `~/.zshrc` - Configurações do shell
- `~/.gitconfig` - Configuração do Git

**Não precisa backup:**
- `~/.cache/` - Recriado automaticamente
- `node_modules/` - Reinstala com npm install
- `.git/` em projetos públicos - Reclona do GitHub

### Backup Rápido

```bash
# Backup das configurações essenciais
tar -czvf ~/backup-config-$(date +%Y%m%d).tar.gz \
    ~/.ssh \
    ~/.gnupg \
    ~/.gitconfig \
    ~/.bashrc \
    ~/.zshrc \
    2>/dev/null

# Backup para nuvem com rclone
rclone sync ~/backup-config.tar.gz gdrive:Backups/
```

---

## Resumo: Checklist de Limpeza

### Limpeza Rápida (5 minutos)

- [ ] Esvaziar lixeira
- [ ] Limpar ~/Downloads antigos
- [ ] `docker system prune -f`
- [ ] Limpar cache de thumbnails

### Limpeza Mensal (15 minutos)

- [ ] Executar `./analise-espaco.sh`
- [ ] Limpar cache de IDEs
- [ ] Limpar cache do npm/pip
- [ ] Revisar extensões de IDEs
- [ ] Remover snaps desabilitados

### Limpeza Profunda (30+ minutos)

- [ ] Backup de dados importantes
- [ ] Executar `./limpeza-profunda.sh`
- [ ] Remover node_modules de projetos antigos
- [ ] Avaliar Docker.raw
- [ ] Revisar arquivos grandes não acessados

---

## Problemas Comuns

### "Disco cheio" mas não encontro onde

```bash
# Verificar arquivos deletados mas ainda abertos
sudo lsof | grep deleted | awk '{print $7, $9}' | sort -rn | head

# Solução: reiniciar o aplicativo que está segurando o arquivo
```

### Espaço não libera após deletar

```bash
# Sync para forçar gravação
sync

# Verificar se há processos segurando arquivos
lsof +D /caminho/deletado
```

### Docker.raw enorme

Veja o guia detalhado em [PROBLEMAS-VSCODE.md](PROBLEMAS-VSCODE.md) na seção Docker.

---

Use este guia como referência e adapte para suas necessidades. A limpeza regular previne problemas de espaço e mantém seu sistema rápido.
