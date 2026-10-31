class_name Drowned
extends CharacterBody3D
## Um Afogado em cena: anda pela navmesh até o alvo que o DrownedBrain escolhe, percebe o
## jogador por distância com oclusão e informa ao diretor os efeitos das ações.

signal effect_triggered(effect: DrownedBrain.Effect)

## Altura dos olhos, de onde parte o raio de percepção.
@export var eye_height: float = 1.6
@export var arrive_distance: float = 0.9
## Máximo de obstáculos contados entre ele e o jogador.
@export var max_occluders: int = 4

var brain: DrownedBrain
var targets: Dictionary[DrownedBrain.Target, Vector3] = {}
var player: Player

var _config: DrownedConfig
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _agent: NavigationAgent3D = %Agent
@onready var _footsteps: LoopingSound = %Footsteps


func setup(
	drowned_config: DrownedConfig,
	threat_config: ThreatConfig,
	target_points: Dictionary[DrownedBrain.Target, Vector3],
	target_player: Player
) -> void:
	_config = drowned_config
	brain = DrownedBrain.new(drowned_config, threat_config)
	targets = target_points
	player = target_player


func _ready() -> void:
	_footsteps.max_distance = _config.footstep_audible_distance


## Um passo de decisão e movimento. `senses` vem do diretor com o estado do farol.
func think(delta: float, senses: DrownedSenses, rng: RandomNumberGenerator) -> void:
	_sense(senses)
	var effect: DrownedBrain.Effect = brain.update(delta, senses, rng)
	if effect != DrownedBrain.Effect.NONE:
		effect_triggered.emit(effect)
	_move(delta)


func is_gone() -> bool:
	return brain.state == DrownedBrain.State.GONE


func _sense(senses: DrownedSenses) -> void:
	var to_player: Vector3 = player.global_position - global_position
	var distance: float = to_player.length()
	var occluders: int = _count_occluders()
	senses.player_in_reach = (
		not player.is_dead and PerceptionRules.is_in_reach(distance, occluders, _config)
	)
	senses.player_in_kill_range = senses.player_in_reach and distance <= _config.kill_distance
	senses.arrived = global_position.distance_to(_target_point()) <= arrive_distance


func _move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	var horizontal := Vector3.ZERO
	if not brain.is_acting() and brain.state != DrownedBrain.State.GONE:
		_agent.target_position = _target_point()
		var next: Vector3 = _agent.get_next_path_position()
		var direction: Vector3 = next - global_position
		direction.y = 0.0
		if direction.length() > 0.05:
			horizontal = direction.normalized() * _config.move_speed
			look_at(global_position + direction, Vector3.UP)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	_footsteps.set_active(horizontal.length() > 0.0)
	move_and_slide()


func _target_point() -> Vector3:
	var target: DrownedBrain.Target = brain.target()
	if target == DrownedBrain.Target.PLAYER:
		return player.global_position
	return targets.get(target, global_position)


func _count_occluders() -> int:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = global_position + Vector3.UP * eye_height
	var to: Vector3 = player.global_position + Vector3.UP * eye_height
	var query := PhysicsRayQueryParameters3D.create(
		from, to, CollisionLayers.WORLD | CollisionLayers.BARRIERS
	)
	var excluded: Array[RID] = []
	var count: int = 0
	while count < max_occluders:
		query.exclude = excluded
		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty():
			break
		count += 1
		excluded.append(hit["rid"])
	return count
