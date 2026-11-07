class_name Chair
extends Node3D
## Cadeira da mesa: interagir senta o jogador de frente para a mesa (o -Z da cadeira).
## Não colide com o jogador, para ele sentar e levantar no mesmo lugar.

## Pés do jogador em `seat.origin`, olhando para o -Z de `seat`.
signal sit_requested(seat: Transform3D, yaw_limit_degrees: float)

## Quanto o olhar vira para cada lado sentado.
@export var yaw_limit_degrees: float = 75.0


## Pede para sentar neste assento, com o limite de giro do olhar.
func _on_sit_point_interacted() -> void:
	sit_requested.emit(global_transform, yaw_limit_degrees)
