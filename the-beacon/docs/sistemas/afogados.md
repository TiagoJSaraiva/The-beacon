# Afogado

## Propósito
A condição de morte (entrega 2; GDD 1.2.10): com o nevoeiro dentro do farol, ele se aproxima, arromba a porta e caça o jogador até o fim da noite.

## Componentes
- `drowned/drowned_approach.gd` (`DrownedApproach`, puro): medidor de aproximação e entrada.
- `drowned/perception_rules.gd` (`PerceptionRules`, puro): alcance com oclusão.
- `drowned/drowned_brain.gd` (`DrownedBrain`, puro): perseguir, bater, cansar, descansar.
- `drowned/drowned.tscn` (`Drowned`, `CharacterBody3D` na camada `drowned`, colide com `world` e `barriers`): navega com `NavigationAgent3D` pela navmesh do interior, conta obstáculos por raio, passos audíveis por proximidade.
- `drowned/drowned_director.gd` (`DrownedDirector`, nó no `World`, recebe `Lighthouse` e `Player` em `setup()`): pontos, aproximação, entrada, efeitos e batidas no alçapão.
- Pontos no farol (`DrownedTargets/*`): `DoorInside` (onde aparece), `TrapdoorBelow` (rampa sob o alçapão), `RestSpot` (térreo).

## Regras
- Cada barco afundado soma um ponto de Afogado; os pontos passam de uma noite para a outra (`RunState`).
- **Aproximação**: medidor de 0 a 1. Sobe com o nevoeiro em `GROUND_FLOOR` ou acima e ao menos um ponto, a `approach_base_per_second + approach_per_point_per_second × pontos`. Com o nevoeiro fora do farol, desce a `approach_recede_per_second`. O barulho vem de fora da porta (`EntranceDoor.show_approach`) e cresce com o medidor.
- **Entrada**: com o medidor cheio, arromba a porta (som e a folha abrindo e voltando; a porta segue fechada) e aparece do lado de dentro. No máximo um por noite; com 0 pontos, não vem. Ele não sai mais, mesmo que o nevoeiro recue.
- **Dentro**:
  - Jogador ao alcance: persegue e mata ao tocar (`kill_distance`).
  - Fora do alcance: vai para baixo do alçapão e bate. Com o trinco ligado, cansa depois de `tire_seconds` (só o tempo de trinco ligado conta), descansa em `RestSpot` por `rest_seconds` e volta. Com o trinco desligado, bate até o alçapão abrir (`TrapdoorConfig.resistance_seconds`, ver `farol.md`).
  - Alçapão aberto: sobe e persegue mesmo sem o jogador ao alcance, até o alçapão fechar.
  - Não sabota nada.
- Alcance: distância + `occlusion_penalty` por obstáculo (`world`/`barriers`) entre os olhos dele e os do jogador, comparado a `perception_range`.
- Mais lento que o jogador (`move_speed`). A noite seguinte começa sem ele e com o medidor zerado.

## Comportamento atual a revisar
A feature ainda vai mudar; isto descreve o código de hoje, sem correção prevista.

- **O jogador perto do alçapão impede as batidas.** O alcance vale com `distância + occlusion_penalty × obstáculos ≤ perception_range` (6 e 10 nas três dificuldades): até 10 m sem obstáculo, até 4 m com um, nunca com dois ou mais. As distâncias são entre os pés (`global_position`); os obstáculos, contados num raio entre os dois na altura dos olhos (`Drowned._count_occluders`).
  - `TrapdoorBelow` fica cerca de 2 m abaixo do piso da cabine. Com um obstáculo entre eles (o piso ou o painel), o jogador está ao alcance em qualquer ponto do piso da cabine a até ~3,4 m na horizontal da vertical de `TrapdoorBelow`; em cima do alçapão, a ~2,3 m, dá ~8,3.
  - Ao alcance, o `DrownedBrain` passa a `CHASE` em vez de bater. O caminho até o jogador passa pelo vão do alçapão (a navmesh não tem as barreiras, decisão 0009), então ele sobe a rampa e empurra o painel fechado.
  - Sem bater: `TrapdoorRules.tick` repõe `resistance_seconds` a cada frame, e o tempo de cansaço (`tire_seconds`) não conta. Com o trinco desligado, o alçapão nunca abre; com ele ligado, o Afogado nunca cansa e não vai descansar.
  - Quando o jogador sai do alcance, ele volta a `GO_TRAPDOOR`, chega e recomeça a bater do zero.
  - A confirmar jogando: quantos obstáculos o raio conta com o jogador em cima do alçapão (com dois, ele fica fora do alcance).

## Sinais
- `Drowned.effect_triggered(effect)` → `DrownedDirector` → `Player.kill(CAUSE_DROWNED)`.
- `DrownedDirector.approaching_changed(approaching)`, `drowned_entered` → tutorial.
- `FogSystem.stage_changed` → `DrownedDirector.set_fog_stage`; `BoatDirector.boat_sank` → `add_drowned_point`.

## Testes
- `test/unit/drowned_approach_test.gd`, `drowned_brain_test.gd`, `perception_rules_test.gd`.
- `test/scenes/drowned_entry_test.gd`: com nevoeiro dentro e um ponto, ele entra pela porta, a navmesh tem caminho até o alçapão e ele sai andando.
