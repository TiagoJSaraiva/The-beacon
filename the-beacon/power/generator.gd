class_name Generator
extends Node3D
## Gerador na casa de máquinas. Alimenta lâmpada, relógio e luzes de cima (GDD 1.2.5);
## monitores e rádio não dependem dele.

signal power_changed(powered: bool)
signal broken_changed(broken: bool)
## Jogador segurou E na boca de combustível com o galão; o farol faz a transferência.
signal refuel_requested

# Estado inicial com valores padrão: os consumidores podem consultar antes do configure().
var state: GeneratorState = GeneratorState.new(PowerConfig.new())

var _was_running: bool = true

@onready var _gauge_pivot: Node3D = %GaugePivot
@onready var _repair_point: Interactable = %RepairPoint
@onready var _pour_point: Interactable = %PourPoint
@onready var _broken_light: Light3D = %BrokenLight
@onready var _hum: LoopingSound = %Hum
@onready var _alarm: LoopingSound = %Alarm


func _ready() -> void:
	_refresh()


func _process(delta: float) -> void:
	state.tick(delta)
	_refresh()


func configure(power: PowerConfig, repair_config: RepairConfig) -> void:
	state = GeneratorState.new(power)
	_repair_point.hold_seconds = repair_config.generator_repair_seconds
	_pour_point.hold_seconds = power.jerrycan_pour_seconds
	_refresh()


func is_running() -> bool:
	return state.is_running()


func set_beam_load(active: bool) -> void:
	state.beam_load = active


## Põe combustível e devolve quanto foi aceito.
func add_fuel(amount: float) -> float:
	var accepted: float = state.add_fuel(amount)
	_refresh()
	return accepted


func can_break_down() -> bool:
	return not state.is_broken


func break_down() -> void:
	_set_broken(true)


func repair() -> void:
	_set_broken(false)


func to_dict() -> Dictionary:
	return state.to_dict()


func from_dict(data: Dictionary) -> void:
	state.from_dict(data)
	_refresh()


func _set_broken(broken: bool) -> void:
	if state.is_broken == broken:
		return
	state.is_broken = broken
	_refresh()
	broken_changed.emit(broken)


func _refresh() -> void:
	_gauge_pivot.scale.y = maxf(state.fuel_ratio(), 0.001)
	_repair_point.enabled = state.is_broken
	_broken_light.visible = state.is_broken
	_alarm.set_active(state.is_broken)
	var running: bool = state.is_running()
	_hum.set_active(running)
	if running != _was_running:
		_was_running = running
		power_changed.emit(running)


func _on_repair_point_hold_completed() -> void:
	repair()


func _on_pour_point_hold_completed() -> void:
	refuel_requested.emit()
