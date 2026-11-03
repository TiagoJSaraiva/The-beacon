# Farol (estrutura)

## Propósito
Greybox dos dois andares, escada em caracol, porta de entrada e alçapão (GDD 1.2.4, 1.2.11, 1.2.20).

## Componentes
- `lighthouse/lighthouse.tscn` (`Lighthouse`, `lighthouse.gd`, grupo `navigation_source`): CSG com colisão. Raio interno 5 m; térreo em y=0; cabine (andar de cima) em y=9, sem janelas; teto em 12 m.
- `lighthouse/spiral_staircase.gd` (`@tool`): rampa em segmentos gerada por parâmetros. Hoje: raio interno 3.4, externo 5.0, de 0 a 6.6 m em 0.9 volta, começando em 36° e terminando em 360° (x=4.2, z=0). Guarda-corpo baixo na borda interna enquanto o degrau está abaixo de 1 m.
- `Landing` (patamar em 6.6 m, à frente do fim da escada, x 3.4–4.8, z −0.1–1.5) e `Ramp` (35°, sobe em −X de x=3.4 até x=0 em y=9, z 0.05–1.45).
- Buraco do alçapão no piso de cima: x 0–3.6, z 0–1.5.
- `lighthouse/trapdoor.tscn` (`Trapdoor`): dobradiça na borda longa (z=−0.05); o painel (3.7 × 1.6) abre girando para cima em X. Interativo para abrir e fechar, e trinco ao lado que liga e desliga (regras em `TrapdoorRules`).
- `lighthouse/entrance_door.tscn` (`EntranceDoor`): painel na camada `barriers`; a folha visível anima à parte no arrombamento; barulho de aproximação do lado de fora.
- Térreo: tanque de combustível com o slot do galão (x −2.6, z 1.8) e gerador principal (x −2.6, z −0.3), ligados pela mangueira (`energia-e-combustivel.md`).
- Cabine: mesa com três monitores (dois do mar lado a lado, um da porta), rádio e cadeira (`Chair`, ver `jogador.md`); casa de máquinas (x −0.4, z −2.4) com a tubulação até a cabeça do farol no telhado; gerador de emergência ao lado (x 1.4, z −2.6); alavanca num poste (x −1.65) (`feixe.md`).

## Regras
- Queda do patamar (6.6 m) até o térreo é fatal com a config padrão; do meio da escada, só bloqueia a corrida.
- A geometria evita sobrepor, na mesma posição horizontal, piso andável de níveis diferentes no encontro escada/patamar: o Recast soldava vértices entre eles e quebrava a navmesh. A folga sob o piso de cima onde a rampa passa é de pelo menos 2.1 m.
- Alçapão: `CLOSED` ou `OPEN`. Abre e fecha e liga o trinco só com os pés do jogador acima da dobradiça (`min_user_height`); exige mãos livres.
  - Trinco: liga e desliga com o alçapão fechado, segurando E por `latch_toggle_seconds` (0 = um toque). Trancado, o alçapão não abre.
  - Nevoeiro em `TRAPDOOR` ou acima desliga o trinco e impede ligá-lo; depois de ele sair, só passado `latch_relock_cooldown_seconds`.
  - O Afogado batendo com o trinco desligado abre o alçapão em `resistance_seconds` (acumula enquanto ele bate; recomeça quando para). Aberto por ele, só fecha passado `reclose_cooldown_seconds`.
- Porta: não quebra nem tem conserto; a colisão nunca abre, então o jogador nunca sai do farol. O arrombamento do Afogado é só som e a folha abrindo e voltando.


## Sinais
- `Trapdoor.state_changed(state)`, `Trapdoor.latch_changed(latched)`.
- `Lighthouse.set_fog_stage` → `Trapdoor.set_fog_present`; `DrownedDirector` → `Trapdoor.set_banging`, `EntranceDoor.show_approach`, `EntranceDoor.burst_open`.

## Testes
- `test/unit/trapdoor_rules_test.gd`: trinco só fechado e trava o alçapão; nevoeiro destranca e o intervalo para religar; batidas só abrem destrancado; resistência recomeça; intervalo para fechar depois de aberto pelo Afogado.
- A navegação na escada é coberta por `test/scenes/drowned_entry_test.gd`.
