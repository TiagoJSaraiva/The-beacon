# Feixe do farol e casa de máquinas

## Propósito
Luz giratória que protege os barcos no nevoeiro, e a máquina que a gira (GDD 1.2.7, 1.2.18; decisão 0017).

## Componentes
- `machine_house/machine_house.tscn` (`MachineHouse`, na cabine, regra `FailureState`): carcaça (modelo `machinery_device`) com volante na frente do motor, que gira com o farol operando; tubulação vertical até o telhado; câmara da lâmpada com portinha. Quebrada: luz vermelha, alarme e ponto de conserto (frente, mãos livres). Lâmpada queimada: luz laranja na câmara e ponto de troca na portinha (mãos livres).
- `beam/lighthouse_lamp.tscn` (`LighthouseLamp`, regra `FailureState`): cabeça acima do telhado, na vertical da casa de máquinas. Gira com o farol operando; spot e cone só com o feixe aceso.
- `beam/beam_control.tscn` (`BeamControl`): alavanca num poste ao lado da casa de máquinas, com luz indicadora.
- `beam/beam_state.gd` (`BeamState`, no `Lighthouse`): junta alavanca, energia, lâmpada, casa de máquinas e nevoeiro.

## Regras
- **Operando** = alavanca ligada + energia + lâmpada inteira + casa de máquinas inteira. **Aceso** = operando + nevoeiro sem bloquear (`fog_blocking`, a partir de `NEAR`; ver `nevoeiro.md`).
- Indicador da alavanca: verde = aceso; vermelho = ligada mas sem feixe; apagado = desligada.
- Lâmpada (evento `lamp_burnout`) e casa de máquinas (evento `machine_breakdown`) quebram ao acaso. Depois do conserto, cada uma só volta a quebrar passado o seu intervalo (`RepairConfig.lamp_burnout_cooldown_seconds`, `machine_breakdown_cooldown_seconds`).
- Troca da lâmpada: `lamp_replace_seconds` na portinha da câmara. Reposições infinitas. Conserto da casa de máquinas: `machine_repair_seconds`.
- Início de cada noite: alavanca desligada, lâmpada e casa de máquinas inteiras.

## Sinais
- `BeamControl.switched(on)`, `MachineHouse.broken_changed(broken)`, `MachineHouse.lamp_replaced`, `LighthouseLamp.burned_changed(burned)`, `Generator.power_changed` → `Lighthouse`, que recalcula o farol.
- `Lighthouse.beam_operational_changed(operational)` → `FogSystem`; `Lighthouse.beam_lit_changed(lit)` → `BoatDirector.set_beam_lit`; `FogSystem.stage_changed` → `Lighthouse.set_fog_stage`.

## Testes
- `test/unit/beam_state_test.gd`, `failure_state_test.gd`.
