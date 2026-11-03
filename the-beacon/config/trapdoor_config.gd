class_name TrapdoorConfig
extends Resource
## Alçapão e trinco (entrega 2).

## Tempo de batidas, com o trinco desligado, até o Afogado abrir o alçapão.
@export var resistance_seconds: float = 20.0
## Segurar para ligar ou desligar o trinco. 0 = um toque, sem barra.
@export var latch_toggle_seconds: float = 0.8
## Depois de o nevoeiro sair do alçapão, o trinco só pode ser ligado passado este tempo.
@export var latch_relock_cooldown_seconds: float = 20.0
## Aberto pelo Afogado, o alçapão só pode ser fechado passado este tempo.
@export var reclose_cooldown_seconds: float = 15.0
