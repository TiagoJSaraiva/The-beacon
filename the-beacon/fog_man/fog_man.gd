class_name FogMan
extends CharacterBody3D
## Silhueta do Nevoeiro: atravessa porta e alçapão (só colide com `world`) e vai até o jogador.

@export var chest_height: float = 1.2

var move_speed: float = 2.5

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _agent: NavigationAgent3D = %Agent


## Ponto que a lanterna precisa iluminar.
func chest_position() -> Vector3:
	return global_position + Vector3.UP * chest_height


func chase(delta: float, target: Vector3) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	_agent.target_position = target
	var direction: Vector3 = _agent.get_next_path_position() - global_position
	direction.y = 0.0
	var horizontal := Vector3.ZERO
	if direction.length() > 0.05:
		horizontal = direction.normalized() * move_speed
		look_at(global_position + direction, Vector3.UP)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()
