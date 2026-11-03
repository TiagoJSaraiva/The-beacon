class_name FigureheadConfig
extends Resource
## Carranca (entrega 2). Distâncias em metros.

@export var max_simultaneous: int = 3
## Intervalo mínimo entre duas aparições seguidas, para não surgirem todas de uma vez.
@export var spawn_interval_seconds: float = 12.0
## Não surge mais perto do jogador que isto.
@export var min_spawn_distance: float = 6.0
## Com o jogador a esta distância e à vista, ela pula.
@export var trigger_range: float = 3.0
@export var blind_seconds: float = 4.0
## Cegueiras na noite antes de o ataque seguinte derrubar.
@export var blinds_before_knockdown: int = 2
@export var knockdown_seconds: float = 3.0
## Tempo contínuo sob a lanterna até se dissolver.
@export var dissolve_seconds: float = 0.3
@export var respawn_after_destroyed_seconds: float = 40.0
@export var respawn_after_attack_seconds: float = 40.0
