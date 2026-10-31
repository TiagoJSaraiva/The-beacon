# Eventos

## Propósito
Sorteio de acontecimentos com janelas de horário (GDD 1.2.8): falhas, nevoeiro e barcos.

## Componentes
- `events/event_definition.gd` (`EventDefinition`, Resource): `id`, janela (horas do relógio, pode cruzar a meia-noite), `check_interval_seconds`, `chance_per_check`, `max_per_night`. Arquivos em `config/events/`, listados em cada `DifficultyConfig.events`.
- `events/event_scheduler.gd` (`EventScheduler`, puro): intervalos, janelas, chance e limites.
- `events/event_director.gd` (`EventDirector`, nó no `Game`, `@export night`): roda o sorteio enquanto a noite corre; `register(id, can_trigger, trigger)`.

## Regras
- A cada `check_interval_seconds` reais, se dentro da janela, abaixo do limite da noite e elegível (`can_trigger()`), sorteia `chance_per_check × DifficultyConfig.chance_multiplier_for_night(noite)`.
- Evento sem registro nunca dispara. Contagens e intervalos zeram a cada noite.
- Registrados hoje (`Lighthouse.register_events`): `lamp_burnout` (lâmpada inteira), `hose_rupture` (mangueira inteira), `generator_breakdown` (gerador inteiro). Também `fog` (`FogSystem.register_events`) e `boat` (`BoatDirector.register_events`).

## Sinais
- `EventDirector.event_triggered(event_id)` (para tutorial e depuração).

## Testes
- `test/unit/event_scheduler_test.gd`: intervalo, janela que cruza a meia-noite, chance zero, multiplicador, limite e reset da noite, elegibilidade, ida e volta do save.
