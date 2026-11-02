class_name Agenda
extends Node3D
## Agenda física sobre a mesa da torre: interagir abre o menu sem pausa (GDD 1.2.22).
## Não sabe o que o menu faz; só avisa e diz para onde a câmera deve olhar.

signal open_requested

@onready var _view_target: Marker3D = %ViewTarget


func view_target_position() -> Vector3:
	return _view_target.global_position


func _on_open_point_interacted() -> void:
	open_requested.emit()
