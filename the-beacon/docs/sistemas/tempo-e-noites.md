# Tempo e noites

## Propósito
Horário da noite (20h → 6h) e fim de noite (GDD 1.1, 1.2.1).

## Componentes
- `night/night_clock.gd` (`NightClock`, puro): segundos reais → horário; `is_hour_in_window()` para janelas que cruzam a meia-noite; `set_clock_hour()` (painel de debug) leva o relógio a uma hora, presa no fim da noite.
- `night/night_director.gd` (`NightDirector`, nó no `Game`): faz o relógio andar; `start_night(n)`, chamado uma vez por cena (cada noite é uma carga nova da cena de jogo, decisão 0015).
- `night/wall_clock.tscn` (`WallClock`, `wall_clock.gd`): display digital na parede da cabine; funciona sem energia (decisão 0017, provisório). Vê se está à vista (algum de cinco pontos da caixa dentro do campo de visão da câmera ativa e sem `world` no caminho, num raio por tique de física) e entrega o resultado à regra.
- `night/clock_display_rules.gd` (`ClockDisplayRules`, puro): o texto do visor. Fora da vista, o horário do jogo. À vista, o visor congela no horário daquele instante e corre em tempo real (`WallClock.seconds_per_viewed_minute`, 60 s por minuto do visor, contra 1,5 s por minuto da noite), sem passar do horário do jogo; ao desviar o olhar, volta ao horário do jogo de uma vez. Os minutos contam desde o meio-dia para a virada da meia-noite seguir em frente.

## Regras
- `TimeConfig`: início 20h, fim 6h, 90 s reais por hora → noite de 900 s.
- O relógio para em 06:00 e emite `night_ended` uma vez.
- Fim de noite (`Game`): congela o `World` (`process_mode`), recolhe o estado persistente no `RunState` (`RunCarryover`) e mostra `NightEndScreen` (próxima noite / salvar e sair). Na última noite do contrato, é vitória (ver `menus-e-telas.md`).
- Próxima noite: `SceneRouter.play_night` recarrega a cena; só o que está no `RunState` continua (ver `save-e-progresso.md`).
- `RunState` (puro, `game/run_state.gd`) guarda dificuldade, total de noites e noite atual.
- `night/sky_clock.gd` (`SkyClock`, nó no `World`): a cada minuto, põe o céu (`Sky3D.current_time`) na hora do relógio da noite (decisão 0028).
- `NightDirector.debug_time_scale` acelera só o relógio e só em build de debug.

## Sinais
- `NightDirector.time_changed(text)` (a cada minuto do jogo) → `Game` → `Lighthouse.show_time`.
- `NightDirector.night_started(night)`, `night_ended(night)`.

## Testes
- `test/unit/night_clock_test.gd`: duração, horário exibido, fim e trava em 06:00, janelas, hora definida.
- `test/unit/clock_display_rules_test.gd`: conversão de horário, segue o jogo fora da vista, congela e corre à vista, não passa do jogo, refaz o congelamento, meia-noite.
- `test/scenes/wall_clock_test.gd`: à vista fica congelado com o jogo andando e corre devagar; fora da vista, ou atrás de uma parede, segue o jogo.
- `test/unit/run_state_test.gd`.
- `test/scenes/night_transition_test.gd`: fim de noite congela a simulação, mostra a tela e recolhe o estado persistente; a noite seguinte começa às 20:00 com esse estado e o resto recomeçado.
