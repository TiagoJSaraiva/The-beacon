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


## Sorteia a semente do RNG.
func _ready() -> void:
	rng.randomize()


## Avança os barcos e aplica o desfecho: quem passou some; quem afundou anima e emite
## `boat_sank`. Depois, atualiza o rádio.
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


## Guarda os valores de barcos da dificuldade.
func configure(config: BoatConfig) -> void:
	_config = config


## Registra o evento `boat`, tratado por `can_spawn` e `spawn`.
func register_events(events: EventDirector) -> void:
	events.register(EVENT_BOAT, can_spawn, spawn)


## Diz se há rota e se cabe mais um barco agora.
func can_spawn() -> bool:
	return boat_path != null and _boats.size() < _config.max_simultaneous_boats


## Cria um barco no início da rota e atualiza o rádio.
func spawn() -> void:
	var boat: Boat = boat_scene.instantiate()
	boat.passage = BoatPassage.new(_config.crossing_seconds)
	boat_path.add_child(boat)
	_boats.append(boat)
	_refresh_calling()


## Guarda o trecho da rota coberto pelo nevoeiro, em fração, e atualiza o rádio.
func set_route_fog(start: float, end: float) -> void:
	_fog_start = start
	_fog_end = end
	_refresh_calling()


## Guarda se o feixe está aceso, o que decide o efeito de atender o rádio.
func set_beam_lit(lit: bool) -> void:
	_beam_lit = lit


## Avisa todos os barcos que estão chamando, ao atender o rádio. Com o feixe aceso, eles desviam.
func warn_calling_boats() -> void:
	for boat: Boat in _boats.duplicate():
		if not boat.passage.is_calling(_fog_start, _fog_end):
			continue
		boat.passage.answer(_beam_lit)
		if boat.passage.outcome == BoatPassage.Outcome.DIVERTED:
			_boats.erase(boat)
			boat.divert()
	_refresh_calling()


## Emite `calling_changed` só quando passa a haver ou deixa de haver barco chamando.
func _refresh_calling() -> void:
	var calling: bool = false
	for boat: Boat in _boats:
		calling = calling or boat.passage.is_calling(_fog_start, _fog_end)
	if calling != _calling:
		_calling = calling
		calling_changed.emit(calling)
