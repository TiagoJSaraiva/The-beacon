class_name FogManConfig
extends Resource
## Homem de Nevoeiro (GDD 1.2.10).

@export var move_speed: float = 2.5
## Tempo contínuo sob a lanterna até ele se dissipar.
@export var dissipate_seconds: float = 1.5
@export var blind_seconds: float = 4.0
@export var touch_distance: float = 1.0
## Intervalo mínimo entre duas aparições, mesmo com o nevoeiro forte.
@export var spawn_cooldown_seconds: float = 60.0
