class_name DrownedDirector
extends Node
## Pontos de afogado, nível de ameaça e aparições dos Afogados (GDD 1.2.10). Cada barco
## afundado soma um ponto; a partir do primeiro, eles vão e voltam até o fim do plantão.
## Recebe o farol, o jogador e o exterior do Game em setup().

signal threat_changed(threat: float)
signal drowned_appeared(count: int)

@export var drowned_scene: PackedScene

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var drowned_points: int = 0

var _threat_config: ThreatConfig = ThreatConfig.new()
var _drowned_config: DrownedConfig = DrownedConfig.new()
var _lighthouse: Lighthouse
var _player: Player
var _exterior: Exterior
var _spawn_timer: float = 0.0
var _active: Array[Drowned] = []
var _senses: DrownedSenses = DrownedSenses.new()


func _ready() -> void:
	rng.randomize()


func _physics_process(delta: float) -> void:
	if _lighthouse == null:
		return
	_update_spawning(delta)
	_fill_shared_senses()
	var banging: bool = false
	for drowned: Drowned in _active.duplicate():
		drowned.think(delta, _copy_senses(), rng)
		if drowned.is_gone():
			_remove(drowned)
		elif drowned.brain.state == DrownedBrain.State.BANG_TRAPDOOR:
			banging = true
	_lighthouse.trapdoor.set_banging(banging)


func configure(threat_config: ThreatConfig, drowned_config: DrownedConfig) -> void:
	_threat_config = threat_config
	_drowned_config = drowned_config


func setup(lighthouse: Lighthouse, player: Player, exterior: Exterior) -> void:
	_lighthouse = lighthouse
	_player = player
	_exterior = exterior
	_lighthouse.entrance_door.broken_changed.connect(_on_door_broken_changed)


func threat_level() -> float:
	var door_broken: bool = _lighthouse != null and _lighthouse.entrance_door.is_broken
	return ThreatRules.threat_level(drowned_points, door_broken, _threat_config)


func add_drowned_point() -> void:
	drowned_points += 1
	threat_changed.emit(threat_level())


func active_count() -> int:
	return _active.size()


## Remove todos os Afogados em cena (fim da noite). Pontos e ameaça continuam.
func clear() -> void:
	for drowned: Drowned in _active.duplicate():
		_remove(drowned)
	_spawn_timer = 0.0
	if _lighthouse != null:
		_lighthouse.trapdoor.set_banging(false)


func to_dict() -> Dictionary:
	var drowned_data: Array[Dictionary] = []
	for drowned: Drowned in _active:
		var entry: Dictionary = {
			"position": _vector_to_array(drowned.global_position),
			"exit": _vector_to_array(drowned.targets[DrownedBrain.Target.EXIT]),
			"brain": drowned.brain.to_dict(),
		}
		drowned_data.append(entry)
	return {"drowned_points": drowned_points, "spawn_timer": _spawn_timer, "active": drowned_data}


func from_dict(data: Dictionary) -> void:
	clear()
	drowned_points = data.get("drowned_points", 0)
	_spawn_timer = data.get("spawn_timer", 0.0)
	var saved: Array = data.get("active", [])
	for entry: Dictionary in saved:
		var drowned: Drowned = _spawn_at(_array_to_vector(entry.get("exit", [])))
		drowned.global_position = _array_to_vector(entry.get("position", []))
		drowned.brain.from_dict(entry.get("brain", {}))
	threat_changed.emit(threat_level())


func _update_spawning(delta: float) -> void:
	if drowned_points < 1:
		return
	_spawn_timer += delta
	if _spawn_timer < _threat_config.spawn_check_interval_seconds:
		return
	_spawn_timer = 0.0
	var free_slots: int = _threat_config.max_simultaneous_drowned - _active.size()
	var threat: float = threat_level()
	if free_slots <= 0 or rng.randf() >= ThreatRules.spawn_chance(threat, _threat_config):
		return
	var count: int = ThreatRules.spawn_count(threat, free_slots, _threat_config, rng)
	var spawn_points: Array[Vector3] = _exterior.drowned_spawn_points()
	_fill_shared_senses()
	for i in count:
		var drowned: Drowned = _spawn_at(spawn_points[rng.randi() % spawn_points.size()])
		drowned.brain.start(_copy_senses(), rng)
	drowned_appeared.emit(count)


func _spawn_at(spawn_point: Vector3) -> Drowned:
	var drowned: Drowned = drowned_scene.instantiate()
	var target_points: Dictionary[DrownedBrain.Target, Vector3] = _lighthouse.drowned_targets()
	target_points[DrownedBrain.Target.EXIT] = spawn_point
	drowned.setup(_drowned_config, _threat_config, target_points, _player)
	add_child(drowned)
	drowned.global_position = spawn_point
	drowned.effect_triggered.connect(_on_drowned_effect_triggered)
	_active.append(drowned)
	return drowned


func _remove(drowned: Drowned) -> void:
	_active.erase(drowned)
	drowned.queue_free()


func _fill_shared_senses() -> void:
	_senses.threat = threat_level()
	_senses.door_broken = _lighthouse.entrance_door.is_broken
	_senses.hose_broken = _lighthouse.reserve_tank.state.hose_broken
	_senses.generator_broken = _lighthouse.generator.state.is_broken
	_senses.trapdoor_state = _lighthouse.trapdoor.state


# Cada Afogado preenche a própria percepção, então recebe uma cópia.
func _copy_senses() -> DrownedSenses:
	var copy := DrownedSenses.new()
	copy.threat = _senses.threat
	copy.door_broken = _senses.door_broken
	copy.hose_broken = _senses.hose_broken
	copy.generator_broken = _senses.generator_broken
	copy.trapdoor_state = _senses.trapdoor_state
	return copy


func _on_drowned_effect_triggered(effect: DrownedBrain.Effect) -> void:
	match effect:
		DrownedBrain.Effect.BREAK_DOOR:
			_lighthouse.entrance_door.break_door()
		DrownedBrain.Effect.DAMAGE_HOSE:
			_lighthouse.reserve_tank.break_hose()
		DrownedBrain.Effect.DAMAGE_GENERATOR:
			_lighthouse.generator.break_down()
		DrownedBrain.Effect.KILL:
			_player.kill(Player.CAUSE_DROWNED)


func _on_door_broken_changed(_broken: bool) -> void:
	threat_changed.emit(threat_level())


static func _vector_to_array(vector: Vector3) -> Array[float]:
	return [vector.x, vector.y, vector.z]


static func _array_to_vector(values: Array) -> Vector3:
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(values[0], values[1], values[2])
