# Feixe do farol

## Propósito
Luz giratória que protege os barcos no nevoeiro (GDD 1.2.7, 1.2.18).

## Componentes
- `beam/lighthouse_lamp.tscn` (`LighthouseLamp`, regra `BeamState`): pedestal no centro do andar de cima; cabeça que gira com spot e cone visível; troca da lâmpada segurando E (mãos livres).
- `beam/beam_control.tscn` (`BeamControl`): painel na parede; alavanca e luz indicadora.
- Fiação em `Lighthouse`: interruptor → lâmpada; `beam_active_changed` → consumo extra do gerador, indicador do painel e repasse para fora.

## Regras
- Feixe aceso = interruptor ligado + energia + lâmpada inteira. Só aceso ele gira e gasta mais combustível.
- Indicador: verde = aceso; vermelho = ligado mas sem feixe (sem energia ou lâmpada queimada); apagado = desligado.
- Lâmpadas de reposição são infinitas; a troca leva `RepairConfig.lamp_replace_seconds`.
- Início do plantão: feixe desligado.

## Sinais
- `BeamControl.switched(on)` → `Lighthouse`.
- `LighthouseLamp.beam_active_changed(active)`, `burned_changed(burned)`; `Lighthouse.beam_active_changed(active)` para barcos (passo 14).

## Testes
- `test/unit/beam_state_test.gd`.
