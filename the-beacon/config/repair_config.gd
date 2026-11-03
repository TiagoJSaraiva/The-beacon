class_name RepairConfig
extends Resource
## Falhas com conserto (GDD 1.2.25): duração das interações, em segundos segurando a
## hotkey, e intervalo mínimo entre uma quebra consertada e a próxima.

@export_group("Lâmpada")
@export var lamp_replace_seconds: float = 4.0
@export var lamp_burnout_cooldown_seconds: float = 120.0

@export_group("Casa de máquinas")
@export var machine_repair_seconds: float = 6.0
@export var machine_breakdown_cooldown_seconds: float = 120.0

@export_group("Porta")
@export var door_repair_seconds: float = 5.0
