class_name BeamControl
extends Node3D
## Painel do sistema de iluminação: liga e desliga o feixe e mostra o estado
## (verde = aceso, vermelho = ligado mas sem feixe, apagado = desligado).

signal switched(on: bool)

const COLOR_ACTIVE := Color(0.2, 1.0, 0.3)
const COLOR_FAILURE := Color(1.0, 0.1, 0.05)

@export var lever_angle_degrees: float = 40.0

var is_on: bool = false

@onready var _lever: Node3D = %Lever
@onready var _indicator: OmniLight3D = %Indicator


func _ready() -> void:
	show_status(false)


## Atualiza a alavanca e a luz indicadora conforme o feixe está ou não aceso.
func show_status(beam_active: bool) -> void:
	_lever.rotation.x = deg_to_rad(lever_angle_degrees if is_on else -lever_angle_degrees)
	_indicator.visible = is_on
	_indicator.light_color = COLOR_ACTIVE if beam_active else COLOR_FAILURE


func _on_switch_point_interacted() -> void:
	is_on = not is_on
	switched.emit(is_on)
