class_name Drowned
extends CharacterBody3D
## O Afogado dentro do farol: anda pela navmesh até o alvo que o DrownedBrain escolhe,
## percebe o jogador por distância com oclusão e informa ao diretor os efeitos das ações.
## Na escada de mão (link da navmesh), sobe ou desce em percurso fixo, só com o alçapão aberto.

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
var _trapdoor_open: bool = false
var _ladder: LadderTraversal

@onready var _agent: NavigationAgent3D = %Agent
@onready var _footsteps: LoopingSound = %Footsteps


## Recebe a configuração, os pontos do farol e o jogador, e cria o cérebro. Precisa vir antes de
## entrar na árvore, porque `_ready` usa a configuração.
func setup(
	drowned_config: DrownedConfig,
	target_points: Dictionary[DrownedBrain.Target, Vector3],
	target_player: Player
) -> void:
	_config = drowned_config
	brain = DrownedBrain.new(drowned_config)
	targets = target_points
	player = target_player


## Limita a distância em que os passos são ouvidos e passa a tratar a chegada à escada de mão.
func _ready() -> void:
	_footsteps.max_distance = _config.footstep_audible_distance
	_agent.link_reached.connect(_on_agent_link_reached)


## Executa um passo de decisão e movimento e emite `effect_triggered` se a decisão gerar um
## efeito. `senses` vem do diretor com o estado do farol.
func think(delta: float, senses: DrownedSenses) -> void:
	_sense(senses)
	_trapdoor_open = senses.trapdoor_state == Trapdoor.State.OPEN
	var effect: DrownedBrain.Effect = brain.update(delta, senses)
	if effect != DrownedBrain.Effect.NONE:
		effect_triggered.emit(effect)
	_move(delta)


## Preenche em `senses` se o jogador está ao alcance e na distância de matar, e se ele chegou ao
## alvo.
func _sense(senses: DrownedSenses) -> void:
	var to_player: Vector3 = player.global_position - global_position
	var distance: float = to_player.length()
	var occluders: int = _count_occluders()
	senses.player_in_reach = (
		not player.is_dead and PerceptionRules.is_in_reach(distance, occluders, _config)
	)
	senses.player_in_kill_range = senses.player_in_reach and distance <= _config.kill_distance
	senses.arrived = global_position.distance_to(_target_point()) <= arrive_distance


## Na escada de mão, segue o percurso dela. Fora, aplica a gravidade e, se não estiver parado
## agindo, anda pela navmesh até o alvo do cérebro, com os passos tocando.
func _move(delta: float) -> void:
	if _ladder != null:
		_climb(delta)
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta
	var horizontal := Vector3.ZERO
	if not brain.is_acting():
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


## Avança no percurso da escada de mão, sem física nem passos, e o encerra ao chegar à saída ou
## ao voltar à entrada com o alçapão fechado.
func _climb(delta: float) -> void:
	velocity = Vector3.ZERO
	_footsteps.set_active(false)
	global_position = _ladder.advance(_config.ladder_climb_speed * delta, _trapdoor_open)
	if _ladder.is_finished(_trapdoor_open):
		_ladder = null


## Devolve a posição do alvo atual; sem alvo conhecido, a própria posição.
func _target_point() -> Vector3:
	var target: DrownedBrain.Target = brain.target()
	if target == DrownedBrain.Target.PLAYER:
		return player.global_position
	return targets.get(target, global_position)


## Conta os obstáculos (`world` e `barriers`) entre ele e o jogador na altura dos olhos, até
## `max_occluders`.
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


## Começa o percurso da escada de mão ao chegar à entrada do link, se o alçapão estiver aberto.
## Fechado, ele fica no pé da escada; o agente avisa de novo a cada novo caminho.
func _on_agent_link_reached(details: Dictionary) -> void:
	if _ladder != null or not _trapdoor_open:
		return
	_ladder = LadderTraversal.new(global_position, details["link_exit_position"])
