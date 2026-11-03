# Save e progresso

## Propósito
Um único save da partida, gravado só entre noites, e o desbloqueio permanente das dificuldades (GDD 1.2.14; decisões 0014 e 0015).

## Componentes
- Autoload `SaveService` (`autoload/save_service.gd`): `user://run_save.json` (save) e `user://progress.json` (desbloqueio), arquivos separados.
- `game/run_state.gd` (`RunState`, puro): o plantão e tudo o que passa de uma noite para a outra. É o conteúdo do save.
- `game/run_carryover.gd` (`RunCarryover`, nó no `Game`): aplica o `RunState` aos sistemas ao montar a noite e o recolhe às 06:00.
- `autoload/progress_state.gd` (`ProgressState`, puro): regras do desbloqueio.
- `autoload/run_request.gd` (`RunRequest`): dificuldade e `RunState` que o `SceneRouter` entrega à cena de jogo.

## Regras
- Persistem entre noites: dificuldade, noite atual, pontos de Afogado, mangueira rompida, bateria da lanterna, passos do tutorial já mostrados. Todo o resto recomeça do zero, porque cada noite é uma carga nova da cena de jogo (`SceneRouter.play_night`).
- Só "Salvar e sair", na tela de fim de noite, grava. O save já aponta para a noite seguinte.
- Começar uma noite (plantão novo, próxima noite ou Continuar) apaga o save. Sair no meio da noite (menu de pausa, fechar o jogo, Alt+F4) perde a partida, e Continuar fica desabilitado.
- Também apagam o save: morrer, vencer, escolher dificuldade em Novo Jogo.
- Continuar: o menu monta o `RunState` do save e busca a dificuldade no catálogo; dificuldade desconhecida descarta o save. `version` diferente de `SAVE_VERSION` = sem save.
- Desbloqueio: a primeira do catálogo sempre liberada; vencer libera a seguinte. Nada o desfaz.
- Mudou o formato do `RunState`? Suba `SaveService.SAVE_VERSION` (hoje 3).
- Estado novo que precisa sobreviver à noite: campo no `RunState` e entrada no `RunCarryover`.

## Testes
- `test/unit/run_state_test.gd`: plantão novo, avanço de noites, ida e volta pelo JSON, valores inválidos.
- `test/unit/progress_state_test.gd`.
- `test/scenes/night_transition_test.gd`: às 06:00 o `RunState` recolhe pontos, mangueira e bateria; uma noite montada a partir do save aplica esse estado, recomeça o resto e apaga o save.
