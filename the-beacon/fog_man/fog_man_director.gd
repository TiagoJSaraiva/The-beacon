class_name FogManDirector
extends Node
## Faz surgir o Homem de Nevoeiro quando o nevoeiro cobre a câmera do farol, persegue o
## jogador, dissipa-o com a lanterna e cega o jogador ao toque (GDD 1.2.10).

signal appeared
signal dissipated
signal player_blinded(seconds: float)

@export var fog_man_scene: PackedScene

var tracker: FogManTracker = FogManTracker.new(FogManConfig.new())

var _player: Player
var _exterior: Exterior
var _fog_man: FogMan
var _fog_covers_camera: bool = false


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	tracker.tick_cooldown(delta)
	if tracker.can_spawn(_fog_covers_camera, _fog_man != null):
		_spawn(_exterior.fog_man_spawn_point())
		appeared.emit()
	if _fog_man == null:
		return
	_fog_man.chase(delta, _player.global_position)
	if tracker.update_light(delta, _is_lit()):
		_vanish()
		dissipated.emit()
	elif (
		_fog_man.global_position.distance_to(_player.global_position)
		<= tracker.config.touch_distance
	):
		_vanish()
		player_blinded.emit(tracker.config.blind_seconds)


func configure(config: FogManConfig) -> void:
	tracker = FogManTracker.new(config)


func setup(player: Player, exterior: Exterior) -> void:
	_player = player
	_exterior = exterior


func set_fog_covers_camera(covers: bool) -> void:
	_fog_covers_camera = covers


## Remove o Homem de Nevoeiro sem consequência (fim da noite).
func clear() -> void:
	if _fog_man != null:
		_fog_man.queue_free()
		_fog_man = null


func to_dict() -> Dictionary:
	var data: Dictionary = {"tracker": tracker.to_dict()}
	if _fog_man != null:
		var position: Vector3 = _fog_man.global_position
		data["position"] = [position.x, position.y, position.z]
	return data


func from_dict(data: Dictionary) -> void:
	clear()
	tracker.from_dict(data.get("tracker", {}))
	var position: Array = data.get("position", [])
	if position.size() == 3:
		_spawn(Vector3(position[0], position[1], position[2]))


func _spawn(spawn_point: Vector3) -> void:
	_fog_man = fog_man_scene.instantiate()
	_fog_man.move_speed = tracker.config.move_speed
	add_child(_fog_man)
	_fog_man.global_position = spawn_point


func _vanish() -> void:
	clear()
	tracker.on_vanished()


func _is_lit() -> bool:
	var chest: Vector3 = _fog_man.chest_position()
	if not _player.flashlight.illuminates(chest):
		return false
	# A luz não atravessa paredes, piso nem alçapão fechado.
	var query := PhysicsRayQueryParameters3D.create(
		_player.flashlight.global_position, chest, CollisionLayers.WORLD | CollisionLayers.BARRIERS
	)
	return _fog_man.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
