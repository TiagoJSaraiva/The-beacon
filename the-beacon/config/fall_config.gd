class_name FallConfig
extends Resource
## Quedas (GDD 1.2.15). Alturas em metros.

## A partir desta altura a queda bloqueia a corrida.
@export var sprint_block_height: float = 2.5
## A partir desta altura a queda mata.
@export var fatal_height: float = 6.0
@export var sprint_block_seconds: float = 30.0
