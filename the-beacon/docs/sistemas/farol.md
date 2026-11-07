# Farol (estrutura)

## Propósito
Greybox dos dois andares, escada em caracol, porta de entrada e alçapão (GDD 1.2.4, 1.2.11, 1.2.20).

## Componentes
- `lighthouse/lighthouse.tscn` (`Lighthouse`, `lighthouse.gd`, grupo `navigation_source`): CSG com colisão. Farol cônico: `Outer` e `Inner` são `CSGPolygon3D` girados (32 lados planos). Raio interno de 6,5 m no chão a 5,5 m em y=10,8, reto na cabine; parede de 0,5 m na horizontal; térreo em y=0; cabine (andar de cima) em y=10,8, sem janelas; teto em 13,8 m.
- `lighthouse/spiral_staircase.gd` (`@tool`): rampa em segmentos gerada por parâmetros. Hoje: na base, raio interno 4.9 e externo 6.5; os dois encolhem 0.778 até o topo (`radius_shrink`), acompanhando a parede. Vai de 0 a 8.4 m em 0.9 volta, começando em 36° e terminando em 360° (x≈4.9, z=0). Ao mudar a inclinação da parede, ajuste também `radius_shrink`. Guarda-corpo baixo na borda interna enquanto o degrau está abaixo de 1 m.
- `Landing` (patamar em 8.4 m, à frente do fim da escada, x 4.12–5.52, z −0.1–1.5) e `Ramp` (35°, sobe em −X de x=4.12 até x=0.72 em y=10.8, z 0.05–1.45).
- Passagens (decisão 0019): a raiz de cada cena é o buraco, um `CSGBox3D` de subtração. Para mover, arraste o nó dentro do pai CSG; ele precisa continuar filho direto desse pai.
- `lighthouse/trapdoor.tscn` (`Trapdoor`, filho de `UpperFloor`): buraco no piso de cima em x 0.72–4.32, z 0–1.5. Dobradiça na borda longa (z=−0.05); o painel (3.7 × 1.6) abre girando para cima em X. Interativo para abrir e fechar, e trinco ao lado que liga e desliga (regras em `TrapdoorRules`).
- `lighthouse/entrance_door.tscn` (`EntranceDoor`, filho de `Shell`): buraco e folha de 1,4 × 2,2 m, no centro de uma face plana da parede (−50,625°). A folha é vertical, em r≈6,53, rente à face interna no chão; por dentro, o vão fica mais fundo no alto. Painel na camada `barriers`; a folha visível anima à parte no arrombamento; barulho de aproximação do lado de fora.
- Térreo: tanque de combustível com o slot do galão (x −2.6, z 1.8) e gerador principal (x −2.6, z −0.3), ligados pela mangueira (`energia-e-combustivel.md`).
- Fora da cena da porta, sem acompanhá-la: `DoorInside`, `DoorCamera`/`DoorView` (`exterior-e-cameras.md`) e as fendas `DoorHole2` e `DoorHole3`, acima dela.
- Cabine: mesa com três monitores (dois do mar lado a lado, um da porta), rádio e cadeira (`Chair`, ver `jogador.md`); casa de máquinas (x −0.4, z −2.4) com a tubulação até a cabeça do farol no telhado; gerador de emergência ao lado (x 1.4, z −2.6); alavanca num poste (x −1.65) (`feixe.md`).

## Regras
- Queda do patamar (8.4 m) até o térreo é fatal com a config padrão; do meio da escada, só bloqueia a corrida.
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
