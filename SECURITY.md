# Política de Segurança

## Sobre Este Projeto

O Linux Home Cleanup Toolkit é um conjunto de scripts Bash que executam operações no sistema de arquivos do usuário. Por sua natureza, estes scripts têm acesso a arquivos e podem deletar dados.

## Princípios de Segurança

### 1. Confirmação Obrigatória

Todos os scripts pedem confirmação explícita do usuário antes de qualquer operação de deleção:

```bash
if prompt_confirmation "Deseja continuar?"; then
    # operação destrutiva
fi
```

### 2. Sem Privilégios Desnecessários

- Scripts funcionam com permissões de usuário normal
- `sudo` é solicitado apenas quando estritamente necessário (apt, journalctl)
- Nenhum script requer execução como root

### 3. Escopo Limitado

- Scripts operam apenas dentro do `$HOME` do usuário
- Não modificam arquivos do sistema fora do home
- Não acessam dados de outros usuários

### 4. Transparência

- Todo código é open source e pode ser auditado
- Operações são exibidas antes de executar
- Tamanhos são mostrados antes da deleção

## Versões Suportadas

| Versão | Suportada |
|--------|-----------|
| 1.0.x  | Sim       |

## Reportando Vulnerabilidades

Se você descobrir uma vulnerabilidade de segurança, por favor:

1. **NÃO** abra uma issue pública
2. Envie um email para: [seu-email@exemplo.com]
3. Inclua:
   - Descrição da vulnerabilidade
   - Passos para reproduzir
   - Impacto potencial
   - Sugestão de correção (se tiver)

### Tempo de Resposta

- **Confirmação de recebimento**: 48 horas
- **Avaliação inicial**: 7 dias
- **Correção**: Depende da severidade

## Boas Práticas para Usuários

### Antes de Executar

1. **Leia o código** - Scripts são curtos e legíveis
2. **Faça backup** - Especialmente antes de limpezas profundas
3. **Execute análise primeiro** - Use `analise-espaco.sh` antes de limpar

### Durante a Execução

1. **Leia as confirmações** - Não confirme automaticamente
2. **Verifique os caminhos** - Confirme que são os esperados
3. **Comece conservador** - Use `limpeza-geral.sh` antes de `limpeza-profunda.sh`

### Operações Sensíveis

| Operação | Risco | Reversível |
|----------|-------|------------|
| Limpar cache de IDEs | Baixo | Sim (recria automaticamente) |
| Limpar ~/.cache | Baixo | Sim (recria automaticamente) |
| Remover node_modules | Médio | Sim (npm install) |
| Reset do Docker | Alto | Não (imagens perdidas) |
| Limpar snaps | Médio | Parcial (reinstalar) |

## Auditoria de Código

O código pode ser verificado com ShellCheck:

```bash
shellcheck *.sh scripts/*.sh
```

## Checksums

Para verificar integridade dos scripts após download:

```bash
sha256sum *.sh scripts/*.sh
```

Compare com os checksums publicados nas releases.

## Escopo de Segurança

### O que os scripts fazem

- Analisam uso de espaço em disco
- Deletam arquivos de cache (com confirmação)
- Removem arquivos temporários (com confirmação)
- Limpam logs antigos (com confirmação)

### O que os scripts NÃO fazem

- Não coletam dados do usuário
- Não enviam informações para servidores externos
- Não instalam software adicional
- Não modificam configurações do sistema
- Não executam código remoto

## Contato

- **Issues de segurança**: [email privado]
- **Discussões gerais**: GitHub Issues
- **Autor**: @johnnyvaz
