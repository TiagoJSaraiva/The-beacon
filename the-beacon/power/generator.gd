class_name Generator
extends Node3D
## Gerador (decisão 0017). A mesma cena serve ao gerador principal, alimentado pela
## mangueira do tanque, e ao de emergência, abastecido com o galão. Alimenta só a casa de
## máquinas e a lâmpada; quem decide a fonte ativa é o farol.

signal power_changed(powered: bool)
## Jogador segurou E na boca de combustível com o galão; o farol faz a transferência.
signal refuel_requested

@export var feed: GeneratorState.Feed = GeneratorState.Feed.FUEL

var state: GeneratorState

var _was_running: bool = false

@onready var _gauge: Node3D = %Gauge
@onready var _gauge_pivot: Node3D = %GaugePivot
@onready var _fuel_cap: Node3D = %FuelCap
@onready var _pour_point: Interactable = %PourPoint
@onready var _hum: LoopingSound = %Hum


func _ready() -> void:
	# Valores padrão até o configure(): o farol consulta o estado logo ao montar.
	state = GeneratorState.new(PowerConfig.new(), feed)
	var uses_fuel: bool = feed == GeneratorState.Feed.FUEL
	_gauge.visible = uses_fuel
	_fuel_cap.visible = uses_fuel
	_pour_point.enabled = uses_fuel
	_was_running = state.is_running()
	_refresh()


func _process(delta: float) -> void:
	state.tick(delta)
	_refresh()


func configure(power: PowerConfig) -> void:
	var hose_intact: bool = state.hose_intact
	state = GeneratorState.new(power, feed)
	state.hose_intact = hose_intact
	_pour_point.hold_seconds = power.jerrycan_pour_seconds
	_refresh()


func is_running() -> bool:
	return state.is_running()


func set_hose_intact(intact: bool) -> void:
	state.hose_intact = intact
	_refresh()


func set_in_use(in_use: bool) -> void:
	state.in_use = in_use
	_refresh()


func _refresh() -> void:
	_gauge_pivot.scale.y = maxf(state.fuel_ratio(), 0.001)
	var running: bool = state.is_running()
	# O de emergência só faz barulho quando está de fato alimentando o farol.
	_hum.set_active(running and (feed == GeneratorState.Feed.HOSE or state.in_use))
	if running != _was_running:
		_was_running = running
		power_changed.emit(running)


func _on_pour_point_hold_completed() -> void:
	refuel_requested.emit()
