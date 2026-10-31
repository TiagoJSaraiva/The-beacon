# Jogador

## Propósito
Controle em primeira pessoa (andar, correr, agachar, olhar), quedas e lanterna. Sem pulo (GDD 1.2.20).

## Componentes
- `player/player.tscn` → `Player` (`CharacterBody3D`): movimento e olhar; `kill(cause)`, `apply_slow()`, `set_controls_enabled()`. Expõe `interaction` e `flashlight`.
  - `Head/Camera3D/InteractionRay`: mira de interação (ver `interacao.md`).
  - `Head/Camera3D/Flashlight` (`player/flashlight.tscn`): lanterna na mão esquerda.
  - `FallDamage`: mede a altura de cada queda.
- Regras puras: `FallRules` (altura → nada / lento / fatal), `FlashlightBattery`, `FlashlightCone`.

## Regras
- Velocidades por `@export` no `Player` (andar 3.5, correr 5.5, agachar 1.6 m/s). Agachar só baixa a câmera e a velocidade.
- Queda: altura = pico − pouso. `>= FallConfig.slow_height` deixa lento (`slow_speed_multiplier` por `slow_seconds`); `>= fatal_height` mata (`CAUSE_FALL`).
- Lanterna: Z liga/desliga; segurar X traz o display de carga (`Label3D` no corpo) para a frente da câmera, sem parar o movimento. A bateria (`FlashlightConfig.battery_seconds`) só gasta ligada e não recarrega; zerada, apaga e não liga mais.
- `Flashlight.illuminates(point)` diz se um ponto está no cone aceso (alcance e meio-ângulo da config); obstáculos são checados por quem pergunta.
- Em build de debug, Esc solta/captura o mouse (o jogo não tem pausa).
- Efeitos de tela (não são HUD de estado): borda vermelha enquanto lento por queda (`Hud.set_slowed`) e tela preta do toque do Homem de Nevoeiro (`Hud.show_blindness`).

## Sinais
- `Player.died(cause)`, `Player.slowed_changed(active)`.
- `FallDamage.slowed(seconds, multiplier)`, `FallDamage.fatal_fall` → `Player`.
- `Flashlight.toggled(lit)`, `Flashlight.battery_depleted`.

## Testes
- `test/unit/fall_rules_test.gd`, `flashlight_battery_test.gd`, `flashlight_cone_test.gd`.
- `test/scenes/player_test.gd`: velocidade de caminhada (faixa), queda média deixa lento, queda alta mata.
