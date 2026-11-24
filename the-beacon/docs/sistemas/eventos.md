# Eventos

## Propósito
Sorteio de acontecimentos com janelas de horário (GDD 1.2.8): falhas, nevoeiro e barcos.

## Componentes
- `events/event_definition.gd` (`EventDefinition`, Resource): `id`, janela (horas do relógio, pode cruzar a meia-noite), `check_interval_seconds`, `chance_per_check`, `max_per_night`. Arquivos em `config/events/`, listados em cada `DifficultyConfig.events`. Os valores de cada noite vêm da tabela da dificuldade (linhas `events/<id>.<campo>`, decisão 0031), aplicados numa cópia: o `.tres` do evento é compartilhado, mas os valores não.
- `events/event_scheduler.gd` (`EventScheduler`, puro): intervalos, janelas, chance e limites.
- `events/event_director.gd` (`EventDirector`, nó no `Game`, `@export night`): roda o sorteio enquanto a noite corre; `register(id, can_trigger, trigger)`. Para o painel de debug: `trigger_now(id)`, `registered_events()` e `random_events_enabled`.

## Regras
- A cada `check_interval_seconds` reais, se dentro da janela, abaixo do limite da noite e elegível (`can_trigger()`), sorteia `chance_per_check × event_chance_multiplier`, os dois da noite (a tabela tem uma coluna por noite; o aumento de chance a cada noite está nela).
- Evento sem registro nunca dispara. Contagens e intervalos zeram a cada noite.
- Disparo manual (`trigger_now`, painel de debug): só se o sistema aceitar (`can_trigger()`), fora do sorteio e sem contar no máximo da noite. Com `random_events_enabled` desligado, o sorteio para.
- Registrados hoje (`Lighthouse.register_events`): `lamp_burnout` (lâmpada inteira e fora do intervalo depois da troca), `machine_breakdown` (casa de máquinas inteira e fora do intervalo depois do conserto). Também `fog` (`FogSystem.register_events`) e `boat` (`BoatDirector.register_events`).

## Sinais
- `EventDirector.event_triggered(event_id)` (para tutorial e depuração).

## Testes
- `test/unit/event_director_test.gd`: disparo manual.
- `test/unit/event_scheduler_test.gd`: intervalo, janela que cruza a meia-noite, chance zero, multiplicador, limite e reset da noite, elegibilidade.
