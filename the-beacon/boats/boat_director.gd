class_name BoatDirector
extends Node
## Faz os barcos cruzarem o mar quando o evento `boat` dispara (até
## `max_simultaneous_boats` ao mesmo tempo) e decide se passam, afundam ou desviam.

## Algum barco precisa de aviso: o rádio toca enquanto for verdade.
signal calling_changed(calling: bool)
signal boat_sank

const EVENT_BOAT := &"boat"

@export var boat_scene: PackedScene

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var boat_path: Path3D

var _config: BoatConfig = BoatConfig.new()
var _boats: Array[Boat] = []
var _fog_start: float = 0.0
var _fog_end: float = 0.0
var _beam_lit: bool = false
var _calling: bool = false


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	for boat: Boat in _boats.duplicate():
		boat.passage.tick(delta, _fog_start, _fog_end)
		match boat.passage.outcome:
			BoatPassage.Outcome.PASSED:
				_boats.erase(boat)
				boat.queue_free()
			BoatPassage.Outcome.SANK:
				_boats.erase(boat)
				boat.sink()
				boat_sank.emit()
	_refresh_calling()


func configure(config: BoatConfig) -> void:
	_config = config


func register_events(events: EventDirector) -> void:
	events.register(EVENT_BOAT, can_spawn, spawn)


func can_spawn() -> bool:
	return boat_path != null and _boats.size() < _config.max_simultaneous_boats


func spawn() -> void:
	var boat: Boat = boat_scene.instantiate()
	boat.passage = BoatPassage.new(_config.crossing_seconds)
	boat_path.add_child(boat)
	_boats.append(boat)
	_refresh_calling()


func set_route_fog(start: float, end: float) -> void:
	_fog_start = start
	_fog_end = end
	_refresh_calling()


func set_beam_lit(lit: bool) -> void:
	_beam_lit = lit


## Rádio atendido: vale para todos os barcos que estão chamando.
func warn_calling_boats() -> void:
	for boat: Boat in _boats.duplicate():
		if not boat.passage.is_calling(_fog_start, _fog_end):
			continue
		boat.passage.answer(_beam_lit)
		if boat.passage.outcome == BoatPassage.Outcome.DIVERTED:
			_boats.erase(boat)
			boat.divert()
	_refresh_calling()


func _refresh_calling() -> void:
	var calling: bool = false
	for boat: Boat in _boats:
		calling = calling or boat.passage.is_calling(_fog_start, _fog_end)
	if calling != _calling:
		_calling = calling
		calling_changed.emit(calling)
