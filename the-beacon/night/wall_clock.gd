class_name WallClock
extends Node3D
## Relógio digital fixo na parede (GDD 1.1). Sem energia, o display apaga.

var is_powered: bool = true

var _text: String = "20:00"

@onready var _display: Label3D = %Display


func show_time(text: String) -> void:
	_text = text
	_refresh()


func set_powered(powered: bool) -> void:
	is_powered = powered
	_refresh()


func _refresh() -> void:
	_display.text = _text if is_powered else ""
