# Tempo e noites

## Propósito
Horário da noite (20h → 6h) e fim de noite (GDD 1.1, 1.2.1).

## Componentes
- `night/night_clock.gd` (`NightClock`, puro): segundos reais → horário; `is_hour_in_window()` para janelas que cruzam a meia-noite.
- `night/night_director.gd` (`NightDirector`, nó no `Game`): faz o relógio andar; `start_night(n)`.
- `night/wall_clock.tscn` (`WallClock`): display digital na parede do andar superior; apaga sem energia.

## Regras
- `TimeConfig`: início 20h, fim 6h, 90 s reais por hora → noite de 900 s.
- O relógio para em 06:00 e emite `night_ended` uma vez.
- Fim de noite (`Game`): congela o `World` (`process_mode`), remove barco, Afogados, Homem de Nevoeiro e nevoeiro, e mostra `NightEndScreen` (continuar / menu). Na última noite do contrato, emite `run_won`. Recursos, danos, pontos de afogado e posições continuam para a noite seguinte.
- `RunState` (puro, `game/run_state.gd`) guarda dificuldade, total de noites e noite atual.
- `NightDirector.debug_time_scale` acelera só o relógio e só em build de debug.

## Sinais
- `NightDirector.time_changed(text)` (a cada minuto do jogo) → `Game` → `Lighthouse.show_time`.
- `NightDirector.night_started(night)`, `night_ended(night)`.

## Testes
- `test/unit/night_clock_test.gd`: duração, horário exibido, fim e trava em 06:00, janelas, ida e volta do save.
- `test/unit/run_state_test.gd`.
- `test/scenes/night_transition_test.gd`: fim de noite congela a simulação e mostra a tela; continuar começa a noite 2 às 20:00 mantendo o gerador quebrado.
