# Tutorial

## Propósito
Tutorial integrado ao jogo (GDD 9.1): em toda partida no Easy, na primeira vez que cada situação acontece, um texto curto aparece na HUD. Não pausa, não pode ser pulado, os sorteios seguem normais.

## Componentes
- `tutorial/tutorial_content.tres` (`TutorialContent`): lista de `TutorialStep` (id + texto) e `message_seconds`.
- `tutorial/tutorial_tracker.gd` (`TutorialTracker`, puro): quais passos já apareceram; termina com todos.
- `tutorial/tutorial_director.gd` (`TutorialDirector`, nó no `World`): recebe os sistemas em `setup()`, escuta os sinais e emite `message_changed(text)` → `Hud.show_tutorial`.

## Regras
- Ativo quando `DifficultyConfig.tutorial_enabled` (hoje só Easy).
- Gatilhos: início da 1ª noite (`start`, `flashlight`), combustível do gerador de emergência abaixo de `low_fuel_ratio` (`low_fuel`), galão na mão (`jerrycan`), lâmpada queimada, mangueira estourada (`hose_burst`), casa de máquinas quebrada (`machine_broken`), porta quebrada, nevoeiro, barco chegando, Afogados aparecendo, Homem de Nevoeiro.
- Textos que chegam juntos entram numa fila; cada um fica `message_seconds` na tela.
- Mudar um texto: só o `.tres`. Passo novo: o id em `TutorialDirector.KNOWN_STEPS` e o gatilho no `setup()`, mais o texto no `.tres` (o teste reprova conteúdo com id desconhecido ou faltando).
- Os passos já mostrados passam de uma noite para a outra (`RunState.tutorial_shown_ids`) e vão no save.

## Sinais
- `TutorialDirector.message_changed(text)`.

## Testes
- `test/unit/tutorial_tracker_test.gd`: primeira vez só, id desconhecido, fim, retomada de noites anteriores, conteúdo coerente com `KNOWN_STEPS`.
