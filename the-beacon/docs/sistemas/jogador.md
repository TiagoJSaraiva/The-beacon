# Jogador

## Propósito
Controle em primeira pessoa (andar, correr, pular, olhar com mouse ou analógico), quedas, cadeira e lanterna.

## Componentes
- `player/player.tscn` → `Player` (`CharacterBody3D`): movimento, pulo e olhar; `sit(seat, yaw_limit_degrees)`, `knock_down(seconds)`, `kill(cause)`, `set_controls_enabled()`, `set_carrying()`. A carga da bateria passa de uma noite para a outra (`Flashlight.set_battery_seconds`, via `RunCarryover`). Expõe `interaction` e `flashlight`.
  - `Head/Camera3D/InteractionRay`: mira de interação (ver `interacao.md`).
  - `Head/Camera3D/Flashlight` (`player/flashlight.tscn`): lanterna na mão esquerda, com a barra de carga (`BatteryGauge`) no corpo.
  - `FallDamage`: mede a altura de cada queda e conta o bloqueio da corrida.
- `player/chair.tscn` (`Chair`): cadeira da mesa da cabine, instanciada no `Lighthouse`. Não colide com o jogador.
- Regras puras: `FallRules` (altura → nada / corrida bloqueada / fatal), `SeatRules` (limite do olhar sentado), `FlashlightBattery`, `FlashlightCone`.

## Regras
- Velocidades por `@export` no `Player` (andar 3.5, correr 5.5 m/s). O analógico esquerdo inclinado pela metade anda mais devagar.
- Pulo: só no chão, `jump_velocity` 4.0 m/s (cerca de 0,8 m). Não há agachar.
- Olhar: mouse (`mouse_sensitivity`) ou analógico direito (`stick_look_degrees_per_second`), os dois multiplicados por `sensitivity_scale`, que vem de `Settings` pelo `Game`.
- Queda: altura = pico − pouso. `>= FallConfig.sprint_block_height` bloqueia a corrida por `sprint_block_seconds` (30 s; outra queda média recomeça a contagem); `>= fatal_height` mata (`CAUSE_FALL`).
- Cadeira: interagir senta com os pés no ponto da cadeira, de frente para a mesa, com a cabeça mais baixa (`seated_head_height`). O olhar vira até `Chair.yaw_limit_degrees` (75°) para cada lado. Sentado dá para usar o que estiver ao alcance (monitores, rádio). Qualquer movimento ou o pulo levanta no mesmo lugar.
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
- `test/unit/fall_rules_test.gd`, `seat_rules_test.gd`, `flashlight_battery_test.gd`, `flashlight_cone_test.gd`.
- `test/scenes/player_test.gd`: velocidade de caminhada (faixa), queda média bloqueia a corrida, queda alta mata; altura do pulo (faixa); sentar segura o jogador parado e mover levanta; a derrubada segura o jogador, bloqueia interagir e sentar, e depois o solta (com os controles desligados, a interação segue desligada).
