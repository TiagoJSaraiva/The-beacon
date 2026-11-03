class_name FogSystem
extends Node
## Roda o nevoeiro da noite conforme o farol opera e avisa o estágio e o trecho da rota dos
## barcos coberto. Os visuais leem o `state` direto.

signal stage_changed(stage: FogStage.Stage)
## Trecho da rota dos barcos coberto, em fração da rota. Vazio (0, 0) sem nevoeiro.
signal route_fog_changed(start: float, end: float)

const EVENT_FOG := &"fog"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: FogState = FogState.new(FogConfig.new())

var _beam_operational: bool = false
var _published_stage: FogStage.Stage = FogStage.Stage.NONE
var _published_route: Vector2 = Vector2.ZERO


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	state.tick(delta, _beam_operational, rng)
	_publish()


func configure(config: FogConfig) -> void:
	state = FogState.new(config)
	_publish()


func register_events(events: EventDirector) -> void:
	events.register(EVENT_FOG, can_start, start)


func can_start() -> bool:
	return state.can_start()


func start() -> void:
	state.start(rng)


func set_beam_operational(operational: bool) -> void:
	_beam_operational = operational


func _publish() -> void:
	var stage: FogStage.Stage = state.stage()
	if stage != _published_stage:
		_published_stage = stage
		stage_changed.emit(stage)
	var route: Vector2 = state.route_segment()
	if not route.is_equal_approx(_published_route):
		_published_route = route
		route_fog_changed.emit(route.x, route.y)
