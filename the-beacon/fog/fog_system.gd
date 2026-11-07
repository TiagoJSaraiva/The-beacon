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


## Sorteia a semente do RNG.
func _ready() -> void:
	rng.randomize()


## Avança o nevoeiro conforme o farol e publica o que mudou.
func _process(delta: float) -> void:
	state.tick(delta, _beam_operational, rng)
	_publish()


## Recria o nevoeiro com a configuração da dificuldade e publica o estado inicial.
func configure(config: FogConfig) -> void:
	state = FogState.new(config)
	_publish()


## Registra o evento `fog`, tratado por `can_start` e `start`.
func register_events(events: EventDirector) -> void:
	events.register(EVENT_FOG, can_start, start)


## Diz se o evento pode fazer o nevoeiro surgir agora.
func can_start() -> bool:
	return state.can_start()


## Faz o nevoeiro surgir no mar.
func start() -> void:
	state.start(rng)


## Guarda se o farol está operando, o que decide se o nevoeiro avança ou recua.
func set_beam_operational(operational: bool) -> void:
	_beam_operational = operational


## Emite `stage_changed` e `route_fog_changed` só quando os valores mudam.
func _publish() -> void:
	var stage: FogStage.Stage = state.stage()
	if stage != _published_stage:
		_published_stage = stage
		stage_changed.emit(stage)
	var route: Vector2 = state.route_segment()
	if not route.is_equal_approx(_published_route):
		_published_route = route
		route_fog_changed.emit(route.x, route.y)
