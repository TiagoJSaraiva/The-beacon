# Agenda

## Propósito
Menu durante a partida, sem pausa (GDD 1.2.22): configurações, salvar e sair, sair sem salvar.

## Componentes
- `agenda/agenda.tscn` (`Agenda`): objeto na mesa da torre (filho de `Lighthouse/Desk`), com `Interactable` (toque, mãos livres ou não) e o ponto `ViewTarget`. Emite `open_requested`.
- `agenda/agenda_overlay.tscn` (`AgendaOverlay`, `CanvasLayer` no `Game`): páginas clicáveis. Índice (Configurações, Salvar e sair, Sair sem salvar, Fechar), configurações (`SettingsPanel`) e confirmação de sair sem salvar.
- `game/agenda_controller.gd` (`AgendaController`, nó no `Game`): trava o jogador, vira o olhar (`Player.view_focus`), abre o overlay e executa as opções.

## Regras
- O `World` continua rodando com a agenda aberta: Afogados, nevoeiro e relógio seguem, e o jogador continua vulnerável.
- Fechar (botão ou Esc no índice) devolve o olhar anterior e os controles. Esc numa subpágina volta ao índice.
- Morte ou fim da noite com a agenda aberta: ela fecha sem devolver o controle.
- Salvar e sair grava o `RunSnapshot` e vai ao menu. Sair sem salvar apaga o save (inclusive um anterior), depois de confirmar.

## Sinais
- `Agenda.open_requested` → `AgendaController`.
- `AgendaOverlay.closed`, `save_and_exit_requested`, `exit_without_saving_requested` → `AgendaController`.

## Testes
- O fluxo salvar → continuar → sair sem salvar foi validado por sonda headless. A restauração tem teste de cena (`save-e-progresso.md`).
