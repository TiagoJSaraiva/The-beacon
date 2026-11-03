class_name LighthouseLamp
extends Node3D
## Cabeça do farol, acima do telhado: gira com o farol operando e mostra o feixe aceso
## (GDD 1.2.7). A lâmpada queima ao acaso; a troca é feita na câmara da lâmpada, na casa
## de máquinas, e as reposições são infinitas (GDD 1.2.18).

signal burned_changed(burned: bool)

@export var rotation_speed_degrees: float = 36.0

var failure: FailureState = FailureState.new()

var _turning: bool = false

@onready var _head: Node3D = %Head
@onready var _beam: Node3D = %Beam


func _ready() -> void:
	_beam.visible = false


func _process(delta: float) -> void:
	failure.tick(delta)
	if _turning:
		_head.rotate_y(deg_to_rad(rotation_speed_degrees) * delta)


func configure(repair_config: RepairConfig) -> void:
	failure = FailureState.new(repair_config.lamp_burnout_cooldown_seconds)


## Gira com o farol operando; o feixe só aparece aceso.
func show_beam(operational: bool, lit: bool) -> void:
	_turning = operational
	_beam.visible = lit


func is_burned() -> bool:
	return failure.is_broken


func can_burn_out() -> bool:
	return failure.can_break()


func burn_out() -> void:
	if not failure.can_break():
		return
	failure.break_down()
	burned_changed.emit(true)


func replace() -> void:
	if not failure.is_broken:
		return
	failure.repair()
	burned_changed.emit(false)
