# Farol (estrutura)

## Propósito
Greybox dos dois andares, escada em caracol, porta de entrada e alçapão (GDD 1.2.4, 1.2.11, 1.2.20).

## Componentes
- `lighthouse/lighthouse.tscn` (`Lighthouse`, `lighthouse.gd`, grupo `navigation_source`): CSG com colisão. Raio interno 5 m; térreo em y=0; andar superior em y=9; faixa de janelas de 10 a 11.2 m; teto em 12 m.
- `lighthouse/spiral_staircase.gd` (`@tool`): rampa em segmentos gerada por parâmetros. Hoje: raio interno 3.4, externo 5.0, de 0 a 6.6 m em 0.9 volta, começando em 36° e terminando em 360° (x=4.2, z=0). Guarda-corpo baixo na borda interna enquanto o degrau está abaixo de 1 m.
- `Landing` (patamar em 6.6 m, à frente do fim da escada, x 3.4–4.8, z −0.1–1.5) e `Ramp` (35°, sobe em −X de x=3.4 até x=0 em y=9, z 0.05–1.45).
- Buraco do alçapão no piso de cima: x 0–3.6, z 0–1.5.
- `lighthouse/trapdoor.tscn` (`Trapdoor`): dobradiça na borda longa (z=−0.05); o painel (3.7 × 1.6) abre girando para cima em X. Interativo para abrir e fechar e trinco ao lado (`HOLD_CONTINUOUS`).
- `lighthouse/entrance_door.tscn` (`EntranceDoor`): painel na camada `barriers`, ponto de conserto e parede invisível `player_bounds`.
- Mesa no andar de cima (z=4.2) com os dois monitores e o rádio. Lâmpada em (−1.2, 9, −1.4).

## Regras
- Queda do patamar (6.6 m) até o térreo é fatal com a config padrão; do meio da escada, só deixa lento.
- A geometria evita sobrepor, na mesma posição horizontal, piso andável de níveis diferentes no encontro escada/patamar: o Recast soldava vértices entre eles e quebrava a navmesh. A folga sob o piso de cima onde a rampa passa é de pelo menos 2.1 m.
- Alçapão: estados `CLOSED`, `OPEN`, `BROKEN`. Abre e fecha só com os pés do jogador acima da dobradiça (`min_user_height`); exige mãos livres. O trinco só funciona fechado. Quebrado não tem conserto. Resistência às batidas em `afogados.md`.
- Porta: inteira bloqueia jogador e Afogados; quebrada, o painel some e o conserto (segurar E, `RepairConfig.door_repair_seconds`) fica disponível. O jogador nunca sai pelo vão.

## Sinais
- `Trapdoor.state_changed(state)`, `Trapdoor.latch_held_changed(held)`.
- `EntranceDoor.broken_changed(broken)`.

## Testes
- `test/unit/trapdoor_resistance_test.gd`. A navegação na escada foi validada por sondas headless.
