# Casos de Uso e Cenários Reais

Exemplos práticos de situações comuns e como resolver usando as ferramentas deste repositório.

---

## Caso 1: "Meu SSD de 256GB está cheio e não sei por quê"

### Situação
Desenvolvedor júnior com notebook de 256GB SSD. Sistema mostra 95% de uso, mas não consegue identificar onde está o espaço.

### Diagnóstico

```bash
./analise-espaco.sh
```

**Resultado típico:**

```
DISTRIBUIÇÃO POR DIRETÓRIO (Top 20)
────────────────────────────────────────────────────────
   45.2GiB     32%  .cache
   38.1GiB     27%  projetos
   23.4GiB     17%  snap
   12.8GiB      9%  .config
    8.2GiB      6%  .local
```

### Descobertas
- `~/.cache` com 45GB - nunca foi limpo
- `~/projetos` com 38GB - 28GB são node_modules
- `~/snap/code` com 15GB - VS Code Snap com múltiplas revisões

### Solução

```bash
# Passo 1: Limpar cache geral
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.cache/pip/*

# Passo 2: Limpar node_modules de projetos inativos
find ~/projetos -name "node_modules" -type d -mtime +60 -exec rm -rf {} +

# Passo 3: Limpar snaps antigos
./limpeza-profunda.sh
```

**Resultado: 67GB liberados**

---

## Caso 2: "Docker está consumindo 80GB do meu disco"

### Situação
Desenvolvedor backend que usa Docker diariamente. Docker Desktop mostra apenas 5GB de imagens, mas o sistema mostra 80GB usados pelo Docker.

### Diagnóstico

```bash
# Verificar uso do Docker
docker system df

# Verificar Docker.raw
ls -lh ~/.docker/desktop/vms/0/data/Docker.raw
```

**Resultado:**

```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        3         4.2GB     3.1GB (73%)
Containers      8         1         234MB     234MB (100%)
Local Volumes   23        2         1.2GB     980MB (81%)

Docker.raw: 78GB
```

### O Problema
O Docker.raw é um disco virtual "sparse" que cresce mas não encolhe. Mesmo limpando imagens, o arquivo não diminui.

### Solução

**Opção A: Reduzir via Docker Desktop**
1. Docker Desktop > Settings > Resources
2. Virtual disk limit: reduzir para 32GB
3. Apply & Restart

**Opção B: Reset completo (se pode perder dados)**

```bash
./limpeza-profunda.sh
# Escolha a opção de reset do Docker quando perguntar
```

**Resultado: 72GB liberados**

---

## Caso 3: "Tenho VS Code, Cursor e Windsurf instalados"

### Situação
Desenvolvedor testando diferentes IDEs com IA. Cada IDE está consumindo espaço significativo.

### Diagnóstico

```bash
echo "=== VS Code ==="
du -sh ~/.config/Code/ ~/.vscode/ 2>/dev/null

echo "=== Cursor ==="
du -sh ~/.config/Cursor/ ~/.cursor/ 2>/dev/null

echo "=== Windsurf ==="
du -sh ~/.config/Windsurf/ ~/.windsurf/ 2>/dev/null
```

**Resultado:**

```
=== VS Code ===
8.2G    /home/user/.config/Code/
2.1G    /home/user/.vscode/

=== Cursor ===
6.5G    /home/user/.config/Cursor/
1.8G    /home/user/.cursor/

=== Windsurf ===
4.2G    /home/user/.config/Windsurf/
1.4G    /home/user/.windsurf/
```

**Total: 24.2GB apenas em IDEs!**

### Solução

```bash
# Limpar cache de todos os IDEs
./limpeza-geral.sh --vscode

# Analisar extensões duplicadas
./limpeza-geral.sh --analyze
```

### Otimização Adicional
Se usa principalmente um IDE, desinstale os outros ou pelo menos limpe as extensões:

```bash
# Remover extensões do IDE que não usa mais
rm -rf ~/.windsurf/extensions/*  # Se não usa mais Windsurf
```

**Resultado: 18GB liberados**

---

## Caso 4: "Projeto antigo com 15GB de node_modules"

### Situação
Desenvolvedor frontend com muitos projetos. Um projeto de 2 anos atrás tem 15GB só de dependências.

### Diagnóstico

```bash
# Encontrar todos os node_modules
find ~ -name "node_modules" -type d 2>/dev/null | while read dir; do
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    parent=$(dirname "$dir")
    mod_date=$(stat -c '%y' "$parent/package.json" 2>/dev/null | cut -d' ' -f1)
    echo "$size $mod_date $dir"
done | sort -rh | head -20
```

**Resultado:**

```
15G  2022-03-15  /home/user/projetos/projeto-antigo/node_modules
8.2G 2023-01-20  /home/user/projetos/outro-projeto/node_modules
4.5G 2024-06-10  /home/user/projetos/projeto-atual/node_modules
```

### Solução

```bash
# Remover node_modules de projetos não modificados há 90+ dias
find ~/projetos -name "node_modules" -type d -mtime +90 -exec rm -rf {} + 2>/dev/null

# Para projetos específicos (mantém package-lock.json)
rm -rf ~/projetos/projeto-antigo/node_modules
```

**Para reinstalar quando precisar:**

```bash
cd ~/projetos/projeto-antigo
npm install  # Reinstala tudo do package-lock.json
```

**Resultado: 23GB liberados**

---

## Caso 5: "Tenho muitas imagens e vídeos ocupando espaço"

### Situação
Desenvolvedor que também faz edição de vídeo. Home com 200GB de mídia.

### Diagnóstico

```bash
./analise-espaco.sh
```

**Seção relevante do relatório:**

```
ANÁLISE POR TIPO DE ARQUIVO
────────────────────────────────────────────────────────
>>> Vídeos (.mp4, .mkv, .avi, .mov, .webm)
  Total: 156GiB em 342 arquivos

>>> Imagens (.jpg, .png, .gif, .raw, .psd)
  Total: 45GiB em 12847 arquivos

ARQUIVOS ANTIGOS (>180 dias sem acesso, >50MB)
────────────────────────────────────────────────────────
  2.3GiB    2022-05-10  ~/Videos/projeto-cliente-antigo.mp4
  1.8GiB    2022-08-22  ~/Videos/tutorial-gravado.mkv
```

### Solução

**Não delete!** Faça backup primeiro.

```bash
# 1. Backup para HD externo
rsync -avh --progress ~/Videos /media/externo/Backup/

# 2. Ou para nuvem (Backblaze B2 é barato)
rclone sync ~/Videos b2:meu-bucket/Videos --progress

# 3. Depois de confirmar backup, comprimir vídeos antigos
ffmpeg -i video_antigo.mp4 -c:v libx265 -crf 28 video_comprimido.mp4
# Economia: ~50% do tamanho
```

### Sugestão de Organização

```
~/Midia/
├── Atual/          # Projetos em andamento (SSD)
├── Arquivo/        # Projetos finalizados (HD externo)
└── Backup/         # Cópia na nuvem
```

---

## Caso 6: "Sistema lento após anos de uso"

### Situação
Ubuntu instalado há 3 anos. Sistema está lento e disco está 85% cheio.

### Diagnóstico Completo

```bash
# 1. Análise de espaço
./analise-espaco.sh

# 2. Verificar APT
apt list --installed | wc -l  # Quantos pacotes?

# 3. Verificar snaps
snap list --all | wc -l

# 4. Verificar serviços
systemctl list-unit-files --state=enabled | wc -l
```

### Limpeza Completa

```bash
# Passo 1: Limpeza geral
./limpeza-geral.sh --all

# Passo 2: Limpeza profunda
./limpeza-profunda.sh

# Passo 3: Sistema
sudo apt autoremove -y
sudo apt autoclean
sudo journalctl --vacuum-time=7d

# Passo 4: Snaps
sudo snap set system refresh.retain=2
```

**Resultado: 45GB liberados + sistema mais responsivo**

---

## Caso 7: "Quero manter limpo automaticamente"

### Situação
Desenvolvedor quer automatizar a manutenção para não acumular lixo.

### Solução: Cron Jobs

```bash
# Editar crontab
crontab -e

# Adicionar as seguintes linhas:

# Limpeza semanal (domingo às 3h)
0 3 * * 0 rm -rf ~/.cache/thumbnails/* ~/.cache/pip/* 2>/dev/null

# Análise mensal (dia 1 às 10h)
0 10 1 * * /home/$USER/linux-home-cleanup/analise-espaco.sh > /tmp/analise-mensal.txt 2>&1

# Limpeza de logs de IDEs (quinzenal)
0 4 1,15 * * rm -rf ~/.config/Code/logs/* ~/.config/Cursor/logs/* 2>/dev/null

# Alerta se disco > 80%
0 9 * * * [ $(df /home --output=pcent | tail -1 | tr -d ' %') -gt 80 ] && notify-send "Disco quase cheio!"
```

### Script de Manutenção

```bash
#!/bin/bash
# ~/bin/manutencao.sh

echo "=== Manutenção Automática ==="
echo "Data: $(date)"

# Limpar caches seguros
rm -rf ~/.cache/thumbnails/* 2>/dev/null
rm -rf ~/.cache/pip/* 2>/dev/null

# Docker cleanup (se instalado)
if command -v docker &> /dev/null; then
    docker system prune -f > /dev/null 2>&1
fi

# Mostrar status
echo "Espaço livre: $(df -h /home | tail -1 | awk '{print $4}')"
```

---

## Caso 8: "Preparando para análise com IA"

### Situação
Quer usar ChatGPT/Claude para obter sugestões personalizadas de limpeza.

### Solução

```bash
# Gerar relatório para IA
./scripts/analise-ia.sh > ~/meu-sistema.txt

# Copiar conteúdo e colar no ChatGPT/Claude com o prompt:
# "Analise este relatório do meu sistema Linux e sugira
#  quais diretórios posso limpar com segurança e quais
#  devem ser mantidos. Priorize por espaço liberado."
```

---

## Resumo: Quanto Espaço Esperar Liberar

| Cenário | Espaço Típico |
|---------|---------------|
| Primeira limpeza (sistema de 2+ anos) | 30-80 GB |
| Limpeza mensal regular | 2-5 GB |
| Reset do Docker | 20-60 GB |
| Limpeza de node_modules antigos | 10-40 GB |
| Limpeza de IDEs (múltiplos) | 10-25 GB |
| Migração VS Code Snap → deb | 5-10 GB |

---

Cada caso é único. Use os scripts deste repositório como ponto de partida e adapte para sua situação.
