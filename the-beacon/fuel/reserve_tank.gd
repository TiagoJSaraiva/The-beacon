class_name ReserveTank
extends Node3D
## Tanque de reserva no térreo, com medidor e mangueira para encher o galão.

signal fill_requested
signal hose_broken_changed(broken: bool)

var state: ReserveTankState = ReserveTankState.new(PowerConfig.new())

@onready var _gauge_pivot: Node3D = %GaugePivot
@onready var _fill_point: Interactable = %FillPoint
@onready var _repair_point: Interactable = %RepairPoint
@onready var _leak: Node3D = %Leak
@onready var _alarm: LoopingSound = %Alarm


func _ready() -> void:
	_refresh()


func _process(delta: float) -> void:
	state.tick(delta)
	_gauge_pivot.scale.y = maxf(state.fuel_ratio(), 0.001)


func configure(power: PowerConfig, repair_config: RepairConfig) -> void:
	state = ReserveTankState.new(power)
	_fill_point.hold_seconds = power.jerrycan_fill_seconds
	_repair_point.hold_seconds = repair_config.hose_repair_seconds
	_refresh()


func can_break_hose() -> bool:
	return not state.hose_broken


func break_hose() -> void:
	_set_hose_broken(true)


func repair_hose() -> void:
	_set_hose_broken(false)


func to_dict() -> Dictionary:
	return state.to_dict()


func from_dict(data: Dictionary) -> void:
	state.from_dict(data)
	_refresh()


func _set_hose_broken(broken: bool) -> void:
	if state.hose_broken == broken:
		return
	state.hose_broken = broken
	_refresh()
	hose_broken_changed.emit(broken)


func _refresh() -> void:
	_gauge_pivot.scale.y = maxf(state.fuel_ratio(), 0.001)
	_fill_point.enabled = not state.hose_broken
	_repair_point.enabled = state.hose_broken
	_leak.visible = state.hose_broken
	_alarm.set_active(state.hose_broken)


func _on_fill_point_hold_completed() -> void:
	fill_requested.emit()


func _on_repair_point_hold_completed() -> void:
	repair_hose()
