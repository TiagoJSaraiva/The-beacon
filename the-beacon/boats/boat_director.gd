class_name BoatDirector
extends Node
## Faz um barco por vez cruzar o mar quando o evento `boat` dispara e decide se ele passa,
## afunda ou (pirata) é guiado pelo feixe.

## `answered` só é verdadeiro ao restaurar um barco cujo rádio já foi atendido.
signal boat_arrived(is_pirate: bool, answered: bool)
signal boat_passed
signal boat_sank
signal pirate_guided
## O barco deixou de precisar de resposta (passou, afundou ou a noite acabou).
signal boat_gone

const EVENT_BOAT := &"boat"

@export var boat_scene: PackedScene

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var boat_path: Path3D

var _config: BoatConfig = BoatConfig.new()
var _boat: Boat
var _fog_intensity: float = 0.0
var _beam_active: bool = false


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	if _boat == null:
		return
	var passage: BoatPassage = _boat.passage
	var was_guided: bool = passage.pirate_guided
	passage.tick(delta, _fog_intensity, _beam_active)
	if passage.pirate_guided and not was_guided:
		pirate_guided.emit()
	match passage.outcome:
		BoatPassage.Outcome.PASSED:
			_boat.queue_free()
			_finish()
			boat_passed.emit()
		BoatPassage.Outcome.SANK:
			_boat.sink()
			_finish()
			boat_sank.emit()


func configure(config: BoatConfig) -> void:
	_config = config


func register_events(events: EventDirector) -> void:
	events.register(EVENT_BOAT, can_spawn, spawn)


func can_spawn() -> bool:
	return _boat == null and boat_path != null


func spawn() -> void:
	_spawn_passage(BoatPassage.new(_config, rng.randf() < _config.pirate_chance))


func set_fog_intensity(intensity: float) -> void:
	_fog_intensity = intensity


func set_beam_active(active: bool) -> void:
	_beam_active = active


func mark_answered() -> void:
	if _boat != null:
		_boat.passage.was_answered = true


## Remove o barco atual sem consequência (fim da noite).
func clear() -> void:
	if _boat == null:
		return
	_boat.queue_free()
	_finish()


func to_dict() -> Dictionary:
	return {"passage": _boat.passage.to_dict() if _boat != null else {}}


func from_dict(data: Dictionary) -> void:
	clear()
	var saved: Dictionary = data.get("passage", {})
	if saved.is_empty():
		return
	var passage := BoatPassage.new(_config, false)
	passage.from_dict(saved)
	_spawn_passage(passage)


func _spawn_passage(passage: BoatPassage) -> void:
	_boat = boat_scene.instantiate()
	_boat.passage = passage
	boat_path.add_child(_boat)
	boat_arrived.emit(passage.is_pirate, passage.was_answered)


func _finish() -> void:
	_boat = null
	boat_gone.emit()
