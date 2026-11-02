# 0013 — Parse dos scripts numa única execução, com autoloads

- **Data**: 2026-11
- **Status**: aceita (substitui 0007)

## Contexto
A 0007 compilava cada `.gd` com `godot --headless --check-only --script`. Com os autoloads da fase E (0010–0012), esse modo falha: o Godot não registra os autoloads em `--check-only`, e todo script que usa `SceneRouter`, `SaveService` ou `Settings` acusa "Identifier not found", embora funcione no jogo. Um script headless comum (`--script`, sem `--check-only`) registra os autoloads e também acusa erros de compilação.

## Decisão
`scripts/check.ps1` mantém a ordem da 0007: versão → `gdformat --check` → `gdlint` → parse → testes. O parse roda `--import` e depois `scripts/parse_check.gd` (fora do `res://`, porque `scripts/` tem `.gdignore`), que recebe todos os `res://*.gd` do projeto depois de `--`, carrega cada um ignorando o cache e sai com código 1 se algum não compilar. A busca por `SCRIPT ERROR|Parse Error|Failed to load script` na saída continua como reforço.

Validado por sabotagem: `var x: int = "texto"` num script que nenhuma cena usa reprova o parse.

## Alternativas descartadas
- **Manter `--check-only` e acessar os autoloads por `get_node("/root/...")`**: o check continua igual, mas o código fica verboso e perde o nome global e a tipagem.
- **Trocar os autoloads por classes com estado `static`**: funciona com `--check-only`, mas o estado global fica implícito e difícil de isolar nos testes.

## Consequências
Uma inicialização do Godot para todos os scripts, em vez de uma por arquivo: o parse fica mais rápido. Os `_ready` dos autoloads rodam durante o parse (leem os arquivos de `user://`, sem gravar nada). Um script novo em `scripts/` não entra no parse; ele é ferramenta, não jogo.
