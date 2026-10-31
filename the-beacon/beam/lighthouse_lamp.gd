class_name LighthouseLamp
extends Node3D
## Lâmpada do farol: acende o feixe e gira enquanto ativa. Pode queimar; a troca é
## infinita e feita segurando E na própria lâmpada (GDD 1.2.18).

signal beam_active_changed(active: bool)
signal burned_changed(burned: bool)

@export var rotation_speed_degrees: float = 36.0

var state: BeamState = BeamState.new()

var _was_active: bool = false

@onready var _head: Node3D = %Head
@onready var _beam: Node3D = %Beam
@onready var _replace_point: Interactable = %ReplacePoint


func _ready() -> void:
	_refresh()


func _process(delta: float) -> void:
	if state.is_active():
		_head.rotate_y(deg_to_rad(rotation_speed_degrees) * delta)


func configure(repair_config: RepairConfig) -> void:
	_replace_point.hold_seconds = repair_config.lamp_replace_seconds


func is_active() -> bool:
	return state.is_active()


func set_switch_on(on: bool) -> void:
	state.switch_on = on
	_refresh()


func set_powered(powered: bool) -> void:
	state.powered = powered
	_refresh()


func can_burn_out() -> bool:
	return not state.lamp_burned


func burn_out() -> void:
	_set_burned(true)


func replace() -> void:
	_set_burned(false)


func to_dict() -> Dictionary:
	return state.to_dict()


func from_dict(data: Dictionary) -> void:
	state.from_dict(data)
	_refresh()


func _set_burned(burned: bool) -> void:
	if state.lamp_burned == burned:
		return
	state.lamp_burned = burned
	_refresh()
	burned_changed.emit(burned)


func _refresh() -> void:
	_beam.visible = state.is_active()
	_replace_point.enabled = state.lamp_burned
	var active: bool = state.is_active()
	if active != _was_active:
		_was_active = active
		beam_active_changed.emit(active)


func _on_replace_point_hold_completed() -> void:
	replace()
