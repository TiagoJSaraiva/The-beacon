# 0007 — Pipeline de verificação com parse por --check-only

- **Data**: 2026-10
- **Status**: aceita (substitui 0005)

## Contexto
A 0005 fazia o parse com `godot --headless --import`. Uma sabotagem mostrou que o `--import` não compila scripts que nenhuma cena usa: um erro de tipo (`var x: int = "texto"`) passou pela etapa de parse e só foi pego porque estava em `test/`. Fora de `test/`, passaria pelo check completo.

## Decisão
`scripts/check.ps1` encadeia: versão do Godot → `gdformat --check` → `gdlint` → parse → testes gdUnit4. O parse roda `--import` (atualiza cache e `.uid`) e depois `godot --headless --check-only --script` em cada `.gd` do projeto; falha se algum devolver exit code != 0 ou erro de script na saída. `-Fast` roda só `test/unit`; `-Fix` formata antes. Check completo é obrigatório antes de concluir uma tarefa. godot-mcp complementa com execução do jogo e leitura do console.

O parse pega erros de compilação (sintaxe, tipos, identificadores e métodos inexistentes em código tipado), não erros de execução.

## Alternativas descartadas
- **Só `--import`** (0005): não compila scripts não usados.
- **Um script headless que carrega todos os `.gd` de uma vez**: uma única inicialização do Godot, mas é mais código para manter. Vale migrar se o parse por arquivo ficar lento.
- **GUT**: mais simples, mas sem o scene runner de input simulado do gdUnit4.
- **Só rodar o jogo**: pega erros apenas no caminho executado.

## Consequências
O parse custa uma inicialização do Godot por script e cresce com o projeto. Testes de cena são mais lentos e frágeis: no máximo um por mecânica, com asserções por faixa.
