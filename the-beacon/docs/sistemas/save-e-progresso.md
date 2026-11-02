# Save e progresso

## Propósito
Um único save da partida no meio da noite e o desbloqueio permanente das dificuldades (GDD 1.2.14, 1.2.22; decisão 0011).

## Componentes
- Autoload `SaveService` (`autoload/save_service.gd`): `user://run_save.json` (save) e `user://progress.json` (desbloqueio), arquivos separados.
- `autoload/progress_state.gd` (`ProgressState`, puro): regras do desbloqueio.
- `game/run_snapshot.gd` (`RunSnapshot`, nó no `Game`): monta e restaura o conteúdo do save chamando o `to_dict`/`from_dict` de cada sistema.
- `components/save_codec.gd` (`SaveCodec`): `Vector3` ↔ lista para o JSON.
- `autoload/run_request.gd` (`RunRequest`): o que o menu pede ao jogo (dificuldade nova ou save).

## Regras
- Só "Salvar e sair" (agenda) grava. Sem autosave, nem entre noites.
- Apagam o save: morrer, vencer, "Sair sem salvar", escolher dificuldade em Novo Jogo.
- O save guarda: noite e relógio, contadores de eventos, porta, alçapão, gerador, reserva, galão (inclusive na mão), lâmpada e interruptor, jogador (posição, olhar, lentidão, lanterna e bateria), nevoeiro, barco em andamento (com rádio atendido ou não), pontos de afogado e Afogados em cena (posição, saída e estado do cérebro), Homem de Nevoeiro e tracker, passos do tutorial já mostrados.
- Não guarda: sorteios do RNG, fila de textos do tutorial, trinco segurado, progresso de uma interação de duração.
- Restauração: o `Game` resolve a dificuldade pelo `difficulty_id` do save no catálogo; dificuldade desconhecida ou `version` diferente de `SAVE_VERSION` = plantão novo. A noite é retomada sem `night_started`, para não zerar os eventos.
- Desbloqueio: a primeira do catálogo sempre liberada; vencer libera a seguinte. Nada o desfaz.
- Mudou o formato de algum `to_dict`? Suba `SaveService.SAVE_VERSION`.

## Testes
- `test/unit/progress_state_test.gd`; ida e volta do `to_dict` em cada classe de estado.
- `test/scenes/save_restore_test.gd`: salva no meio da noite (via JSON), muda tudo, restaura e confere horário, porta, combustível, pontos de afogado, posição, barco e rádio.
