# Nevoeiro

## Propósito
Ameaça ambiental de intensidade variável (GDD 1.2.10).

## Componentes
- `fog/fog_state.gd` (`FogState`, puro) e `fog/fog_system.gd` (`FogSystem`, nó no `World`).

## Regras
- Começa pelo evento `fog` (`config/events/fog.tres`), só se não houver nevoeiro ativo.
- Dura entre `min_duration_seconds` e `max_duration_seconds`; a cada `retarget_interval_seconds` sorteia um alvo de intensidade entre `min_intensity` e `max_intensity`; a intensidade anda até o alvo a `intensity_change_per_second`. Ao acabar, cai até 0 no mesmo ritmo.
- `is_present()` = intensidade > 0 (barcos permitidos precisam do feixe).
- `covers_lighthouse_camera()` = intensidade >= `fog_man_threshold` (surge o Homem de Nevoeiro).
- Às 06:00 some de imediato (`clear()`).

## Sinais
- `FogSystem.intensity_changed(intensity)` → câmeras e `BoatDirector`.
- `FogSystem.covers_lighthouse_camera_changed(covers)` → `FogManDirector`.

## Testes
- `test/unit/fog_state_test.gd`.
