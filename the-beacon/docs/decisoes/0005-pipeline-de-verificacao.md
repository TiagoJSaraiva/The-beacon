# 0005 — Pipeline de verificação

- **Data**: 2026-10
- **Status**: aceita

## Contexto
Agentes precisam de feedback objetivo para saber se uma mudança está correta antes de declará-la pronta.

## Decisão
`scripts/check.ps1` encadeia: versão do Godot → `gdformat --check` → `gdlint` → parse headless (`--import`) → testes gdUnit4. `-Fast` roda só `test/unit`; `-Fix` formata antes. Check completo é obrigatório antes de concluir uma tarefa. godot-mcp complementa com execução do jogo e leitura do console.

## Alternativas descartadas
- **GUT**: mais simples, mas sem o scene runner de input simulado do gdUnit4.
- **Só rodar o jogo**: pega erros apenas no caminho executado.

## Consequências
Testes de cena são mais lentos e frágeis: no máximo um por mecânica, com asserções por faixa.
