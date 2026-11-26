# Jogador

## Propósito
Controle em primeira pessoa (andar, correr, pular, olhar com mouse ou analógico), quedas, cadeira e lanterna.

## Componentes
- `player/player.tscn` → `Player` (`CharacterBody3D`): movimento, pulo e olhar; `sit(seat, yaw_limit_degrees)`, `knock_down(seconds)`, `kill(cause)`, `set_controls_enabled()`, `set_carrying()`. A carga da bateria passa de uma noite para a outra (`Flashlight.set_battery_seconds`, via `RunCarryover`). Expõe `interaction` e `flashlight`. Para o painel de debug: `invulnerable` (`kill` não mata), `teleport(point)` (em pé, parado, sem contar queda), `is_sprint_blocked()`, `clear_sprint_block()` e `FlashlightBattery.infinite`.
  - `Body` (`player/body/player_body.tscn`, `PlayerBody`): corpo humano (manequim do pacote Quaternius, `assets/models/player_body/`) com a árvore de animação: transição entre parado, andar, trote, pulo, sentado e ajoelhado, mais a velocidade de reprodução. O `Player` chama `update_body(pose, velocity, facing, look_pitch, on_floor, delta)` a cada quadro. As pernas giram na direção do movimento (até 90°; de costas, a animação toca ao contrário, porque o pacote só tem movimento para a frente) e o `TorsoAim` (`SkeletonModifier3D` no esqueleto) desfaz esse giro no tronco e o inclina com o olhar.
  - `Head/Camera3D/InteractionRay`: mira de interação (ver `interacao.md`).
  - `Head/Camera3D/Flashlight` (`player/flashlight.tscn`): lanterna na mão esquerda, com a barra de carga (`BatteryGauge`) no corpo.
  - `FallDamage`: mede a altura de cada queda e conta o bloqueio da corrida.
  - `LadderClimber` (`Area3D`, máscara `ladders`): detecta a zona de agarrar das escadas de mão (`Ladder`, ver `farol.md`) e calcula o movimento agarrado. Ajustes por `@export`: `climb_speed` (2 m/s), `off_floor_horizontal_scale` (0.4), `descend_pitch_degrees` (30°), `top_clearance` (0.1 m).
- `player/chair.tscn` (`Chair`): cadeira da mesa da cabine, instanciada no `Lighthouse`. Não colide com o jogador.
- Regras puras: `LocomotionRules` (`player/body/locomotion_rules.gd`: velocidade local ao corpo, passo, giro das pernas e velocidade da animação), `FallRules` (altura → nada / corrida bloqueada / fatal), `SeatRules` (limite do olhar sentado), `LadderRules` (sentido e velocidade na escada de mão), `FlashlightBattery`, `FlashlightCone`.

## Regras
- Velocidades por `@export` no `Player` (andar 3.5, correr 4.125 m/s). O analógico esquerdo inclinado pela metade anda mais devagar.
- Pulo: só no chão, `jump_velocity` 4.0 m/s (cerca de 0,8 m). Não há agachar.
- Olhar: mouse (`mouse_sensitivity`) ou analógico direito (`stick_look_degrees_per_second`), os dois multiplicados por `sensitivity_scale`, que vem de `Settings` pelo `Game`.
- Queda: altura = pico − pouso. `>= FallConfig.sprint_block_height` bloqueia a corrida por `sprint_block_seconds` (30 s; outra queda média recomeça a contagem); `>= fatal_height` mata (`CAUSE_FALL`).
- Cadeira: interagir senta com os pés no ponto da cadeira, de frente para a mesa, com a cabeça mais baixa (`seated_head_height`). O olhar vira até `Chair.yaw_limit_degrees` (75°) para cada lado. Sentado dá para usar o que estiver ao alcance (monitores, rádio). Qualquer movimento ou o pulo levanta no mesmo lugar.
- Escada de mão: dentro da zona de agarrar não há gravidade nem queda (a medição recomeça ao sair). Frente sobe e trás desce; olhando para baixo além de `descend_pitch_degrees`, a frente desce (é assim que se desce vindo da cabine). No topo, para de subir com os pés `top_clearance` acima do degrau final e segue em frente para o piso. Fora do chão, o horizontal cai a `off_floor_horizontal_scale` e não se afasta da escada; no chão, andar para longe dela não puxa para cima. O pulo não faz nada agarrado. Sobe e desce igual com o galão na mão. Derrubado, fica parado onde está.
- Lanterna: `toggle_flashlight` liga/desliga; segurar `check_battery` traz a barra de carga para a frente da câmera, sem parar o movimento. A bateria (`FlashlightConfig.battery_seconds`) só gasta ligada e não recarrega, nem entre noites; zerada, apaga e não liga mais.
- `Flashlight.illuminates(point)` diz se um ponto está no cone aceso (alcance e meio-ângulo da config); obstáculos são checados por quem pergunta.
- Efeitos de tela (não são HUD de estado): borda vermelha enquanto a corrida está bloqueada (`Hud.set_hurt_border`) e tela preta do pulo da carranca (`Hud.show_blindness`).
- Derrubada (`knock_down(seconds)`, carranca): ajoelha (`kneeling_head_height`), sem andar, pular, interagir (nem sentar) ou soltar o galão; o olhar e a lanterna continuam livres. Tira da cadeira e cancela uma barra de interação em andamento. Ao levantar, a interação volta só se os controles estiverem ligados. `eye_transform()` dá a posição e a direção da câmera.

## Sinais
- `Player.died(cause)`, `Player.sprint_blocked_changed(active)`.
- `FallDamage.sprint_blocked_changed(active)`, `FallDamage.fatal_fall` → `Player`.
- `Chair.sit_requested(seat, yaw_limit_degrees)` → `Game` → `Player.sit`.
- `Flashlight.toggled(lit)`, `Flashlight.battery_depleted`.

## Testes
- `test/unit/locomotion_rules_test.gd`, `test/unit/fall_rules_test.gd`, `seat_rules_test.gd`, `ladder_rules_test.gd`, `flashlight_battery_test.gd`, `flashlight_cone_test.gd`.
- `test/scenes/player_test.gd`: velocidade de caminhada (faixa), queda média bloqueia a corrida, queda alta mata; altura do pulo (faixa); sentar segura o jogador parado e mover levanta; a derrubada segura o jogador, bloqueia interagir e sentar, e depois o solta (com os controles desligados, a interação segue desligada).
- `test/scenes/ladder_climb_test.gd`: com o alçapão aberto, segurar a frente leva o jogador do patamar ao piso da cabine.
