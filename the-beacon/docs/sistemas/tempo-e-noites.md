# Tempo e noites

## Propósito
Horário da noite (20h → 6h) e fim de noite (GDD 1.1, 1.2.1).

## Componentes
- `night/night_clock.gd` (`NightClock`, puro): segundos reais → horário; `is_hour_in_window()` para janelas que cruzam a meia-noite.
- `night/night_director.gd` (`NightDirector`, nó no `Game`): faz o relógio andar; `start_night(n)`, chamado uma vez por cena (cada noite é uma carga nova da cena de jogo, decisão 0015).
- `night/wall_clock.tscn` (`WallClock`): display digital na parede do andar superior; apaga sem energia.

## Regras
- `TimeConfig`: início 20h, fim 6h, 90 s reais por hora → noite de 900 s.
- O relógio para em 06:00 e emite `night_ended` uma vez.
- Fim de noite (`Game`): congela o `World` (`process_mode`), recolhe o estado persistente no `RunState` (`RunCarryover`) e mostra `NightEndScreen` (próxima noite / salvar e sair). Na última noite do contrato, é vitória (ver `menus-e-telas.md`).
- Próxima noite: `SceneRouter.play_night` recarrega a cena; só o que está no `RunState` continua (ver `save-e-progresso.md`).
- `RunState` (puro, `game/run_state.gd`) guarda dificuldade, total de noites e noite atual.
- `NightDirector.debug_time_scale` acelera só o relógio e só em build de debug.

## Sinais
- `NightDirector.time_changed(text)` (a cada minuto do jogo) → `Game` → `Lighthouse.show_time`.
- `NightDirector.night_started(night)`, `night_ended(night)`.

## Testes
- `test/unit/night_clock_test.gd`: duração, horário exibido, fim e trava em 06:00, janelas.
- `test/unit/run_state_test.gd`.
- `test/scenes/night_transition_test.gd`: fim de noite congela a simulação, mostra a tela e recolhe o estado persistente; a noite seguinte começa às 20:00 com esse estado e o resto recomeçado.
