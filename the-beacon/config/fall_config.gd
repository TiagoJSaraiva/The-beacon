class_name FallConfig
extends Resource
## Quedas (GDD 1.2.15 e 1.2.20). Alturas em metros.

## A partir desta altura a queda deixa o jogador lento.
@export var slow_height: float = 2.5
## A partir desta altura a queda mata.
@export var fatal_height: float = 6.0
@export var slow_seconds: float = 4.0
@export_range(0.1, 1.0, 0.05) var slow_speed_multiplier: float = 0.5
