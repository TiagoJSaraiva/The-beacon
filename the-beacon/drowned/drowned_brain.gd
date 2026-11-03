class_name DrownedBrain
extends RefCounted
## Decisões do Afogado dentro do farol (entrega 2). Ele não sai mais.
## - Jogador ao alcance: persegue e mata ao tocar.
## - Fora do alcance: vai para baixo do alçapão e bate. Com o trinco ligado, cansa depois de
##   `tire_seconds`, descansa no térreo por `rest_seconds` e volta. Com o trinco desligado,
##   segue batendo até o alçapão abrir (a resistência é contada pelo alçapão).
## - Alçapão aberto: sobe e persegue, mesmo sem o jogador ao alcance, até o alçapão fechar.

enum State { GO_TRAPDOOR, BANG_TRAPDOOR, REST, CHASE }
enum Target { NONE, TRAPDOOR_BELOW, REST_SPOT, PLAYER }
enum Effect { NONE, KILL }

var state: State = State.GO_TRAPDOOR

var _config: DrownedConfig
var _timer: float = 0.0


func _init(drowned_config: DrownedConfig) -> void:
	_config = drowned_config


## Para onde ele deve andar no estado atual.
func target() -> Target:
	match state:
		State.GO_TRAPDOOR, State.BANG_TRAPDOOR:
			return Target.TRAPDOOR_BELOW
		State.REST:
			return Target.REST_SPOT
		State.CHASE:
			return Target.PLAYER
	return Target.NONE


## Parado agindo, em vez de andar.
func is_acting() -> bool:
	return state == State.BANG_TRAPDOOR or (state == State.REST and _timer > 0.0)


func is_banging() -> bool:
	return state == State.BANG_TRAPDOOR


func update(delta: float, senses: DrownedSenses) -> Effect:
	var trapdoor_open: bool = senses.trapdoor_state == Trapdoor.State.OPEN
	if state != State.CHASE and (senses.player_in_reach or _trapdoor_reached_open(senses)):
		_enter(State.CHASE)
	match state:
		State.CHASE:
			if senses.player_in_kill_range:
				return Effect.KILL
			if not senses.player_in_reach and not trapdoor_open:
				_enter(State.GO_TRAPDOOR)
		State.GO_TRAPDOOR:
			if senses.arrived:
				_enter(State.BANG_TRAPDOOR)
		State.BANG_TRAPDOOR:
			# Só o tempo de trinco ligado cansa.
			if senses.trapdoor_latched:
				_timer += delta
				if _timer >= _config.tire_seconds:
					_enter(State.REST)
		State.REST:
			if senses.arrived or _timer > 0.0:
				_timer += delta
				if _timer >= _config.rest_seconds:
					_enter(State.GO_TRAPDOOR)
	return Effect.NONE


func _trapdoor_reached_open(senses: DrownedSenses) -> bool:
	var at_trapdoor: bool = (
		state == State.BANG_TRAPDOOR or (state == State.GO_TRAPDOOR and senses.arrived)
	)
	return at_trapdoor and senses.trapdoor_state == Trapdoor.State.OPEN


func _enter(new_state: State) -> void:
	state = new_state
	_timer = 0.0
