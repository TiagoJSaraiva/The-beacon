class_name FigureheadDirector
extends Node
## Carrancas (entrega 2): armadilhas imóveis que surgem nas áreas do farol tomadas pelo
## nevoeiro, em pontos aleatórios da navmesh fora da vista do jogador. Com o jogador perto e
## à vista, pulam: cegam e somem; depois de algumas cegueiras, o ataque derruba. Sob a
## lanterna por um instante, se dissolvem. Somem quando o nevoeiro deixa a área delas.

signal appeared
signal dissolved
signal player_blinded(seconds: float)
signal player_knocked_down(seconds: float)

@export var figurehead_scene: PackedScene
## Alturas que separam térreo, escada e cabine no farol.
@export var stairs_from_height: float = 3.84
@export var cabin_from_height: float = 10.6
## Metade do campo de visão considerado ao esconder o ponto de surgimento.
@export var view_half_angle_degrees: float = 60.0
## Pontos aleatórios testados por tentativa de surgir.
@export var spawn_attempts: int = 12

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var tracker: FigureheadTracker = FigureheadTracker.new(FigureheadConfig.new())

var _player: Player
var _stage: FogStage.Stage = FogStage.Stage.NONE
var _figureheads: Array[Figurehead] = []


func _ready() -> void:
	rng.randomize()


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	tracker.tick(delta)
	if FogStage.is_inside(_stage) and tracker.can_spawn(_figureheads.size()):
		_try_spawn()
	for figurehead: Figurehead in _figureheads.duplicate():
		_update(figurehead, delta)


func configure(config: FigureheadConfig) -> void:
	tracker = FigureheadTracker.new(config)


func setup(player: Player) -> void:
	_player = player


func set_fog_stage(stage: FogStage.Stage) -> void:
	_stage = stage
	for figurehead: Figurehead in _figureheads.duplicate():
		if figurehead.is_finishing:
			continue
		if not FigureheadSpawnRules.is_fogged(figurehead.area, stage):
			_figureheads.erase(figurehead)
			figurehead.dissolve()


func _update(figurehead: Figurehead, delta: float) -> void:
	if figurehead.is_finishing:
		return
	figurehead.lit_seconds = figurehead.lit_seconds + delta if _is_lit(figurehead) else 0.0
	if tracker.is_dissolved(figurehead.lit_seconds):
		_figureheads.erase(figurehead)
		tracker.on_destroyed()
		figurehead.dissolve()
		dissolved.emit()
		return
	var distance: float = figurehead.global_position.distance_to(_player.global_position)
	if distance <= tracker.config.trigger_range and _sees_player(figurehead):
		figurehead.landed.connect(_on_figurehead_landed.bind(figurehead))
		figurehead.jump_at(_player.global_position)


func _try_spawn() -> void:
	var map: RID = _player.get_world_3d().navigation_map
	var eye: Transform3D = _player.eye_transform()
	for _attempt: int in spawn_attempts:
		var point: Vector3 = NavigationServer3D.map_get_random_point(map, 1, true)
		var area: FigureheadSpawnRules.Area = FigureheadSpawnRules.area_for_height(
			point.y, stairs_from_height, cabin_from_height
		)
		if not FigureheadSpawnRules.is_fogged(area, _stage):
			continue
		if not FigureheadSpawnRules.is_hidden_and_far(
			point,
			eye.origin,
			-eye.basis.z,
			view_half_angle_degrees,
			tracker.config.min_spawn_distance
		):
			continue
		_spawn(point, area)
		return


func _spawn(point: Vector3, area: FigureheadSpawnRules.Area) -> void:
	var figurehead: Figurehead = figurehead_scene.instantiate()
	figurehead.area = area
	add_child(figurehead)
	figurehead.global_position = point
	figurehead.face(_player.global_position)
	_figureheads.append(figurehead)
	tracker.on_spawned()
	appeared.emit()


func _is_lit(figurehead: Figurehead) -> bool:
	var chest: Vector3 = figurehead.chest_position()
	if not _player.flashlight.illuminates(chest):
		return false
	# A luz não atravessa paredes, piso nem alçapão fechado.
	return _is_clear(_player.flashlight.global_position, chest)


func _sees_player(figurehead: Figurehead) -> bool:
	return _is_clear(figurehead.chest_position(), _player.eye_transform().origin)


func _is_clear(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		from, to, CollisionLayers.WORLD | CollisionLayers.BARRIERS
	)
	return _player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _on_figurehead_landed(figurehead: Figurehead) -> void:
	_figureheads.erase(figurehead)
	figurehead.queue_free()
	match tracker.on_attacked():
		FigureheadTracker.Attack.BLIND:
			player_blinded.emit(tracker.config.blind_seconds)
		FigureheadTracker.Attack.KNOCKDOWN:
			player_knocked_down.emit(tracker.config.knockdown_seconds)
