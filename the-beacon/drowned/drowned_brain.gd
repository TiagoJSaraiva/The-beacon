class_name DrownedBrain
extends RefCounted
## Decisões de um Afogado (GDD 1.2.10), da ação mais leve à mais grave:
## 1 quebrar a porta, 2 danificar a mangueira, 3 danificar o gerador, 4 bater no alçapão.
## - Com a porta inteira, sempre a quebra primeiro.
## - Jogador ao alcance (com a porta já aberta) é sempre o alvo. Perdido o alcance, volta ao
##   que fazia: esconder-se atrás do alçapão não faz a ação subir para o nível 4.
## - Nível 4 só com ameaça >= limiar; abaixo dele, sabota (2 ou 3) e vai embora.
## - Com o alçapão aberto ou quebrado, persegue o jogador até alcançá-lo.

enum State {
	APPROACH_DOOR,
	BREAK_DOOR,
	GO_SABOTAGE,
	SABOTAGE,
	GO_TRAPDOOR,
	BANG_TRAPDOOR,
	CHASE,
	LEAVE,
	GONE,
}
enum Target { NONE, DOOR_OUTSIDE, HOSE, GENERATOR, TRAPDOOR_BELOW, PLAYER, EXIT }
enum Effect { NONE, BREAK_DOOR, DAMAGE_HOSE, DAMAGE_GENERATOR, KILL }

var state: State = State.APPROACH_DOOR
var sabotage_generator: bool = false

var _config: DrownedConfig
var _threat_config: ThreatConfig
var _timer: float = 0.0
var _resume_state: State = State.LEAVE
var _forced_chase: bool = false


func _init(drowned_config: DrownedConfig, threat_config: ThreatConfig) -> void:
	_config = drowned_config
	_threat_config = threat_config


## Primeira decisão ao surgir.
func start(senses: DrownedSenses, rng: RandomNumberGenerator) -> void:
	if senses.door_broken:
		_decide(senses, rng)
	else:
		_enter(State.APPROACH_DOOR)


## Para onde o Afogado deve andar no estado atual.
func target() -> Target:
	match state:
		State.APPROACH_DOOR, State.BREAK_DOOR:
			return Target.DOOR_OUTSIDE
		State.GO_SABOTAGE, State.SABOTAGE:
			return Target.GENERATOR if sabotage_generator else Target.HOSE
		State.GO_TRAPDOOR, State.BANG_TRAPDOOR:
			return Target.TRAPDOOR_BELOW
		State.CHASE:
			return Target.PLAYER
		State.LEAVE:
			return Target.EXIT
	return Target.NONE


## Estados em que ele fica parado agindo, em vez de andar.
func is_acting() -> bool:
	return state in [State.BREAK_DOOR, State.SABOTAGE, State.BANG_TRAPDOOR]


func update(delta: float, senses: DrownedSenses, rng: RandomNumberGenerator) -> Effect:
	if state == State.GONE:
		return Effect.NONE
	if state != State.CHASE and senses.player_in_reach and senses.door_broken:
		_resume_state = state
		_enter(State.CHASE)
	match state:
		State.CHASE:
			return _update_chase(senses)
		State.APPROACH_DOOR:
			if senses.door_broken:
				_decide(senses, rng)
			elif senses.arrived:
				_enter(State.BREAK_DOOR)
		State.BREAK_DOOR:
			if senses.door_broken:
				_decide(senses, rng)
			elif _advance(delta, _config.door_break_seconds):
				_decide(senses, rng)
				return Effect.BREAK_DOOR
		State.GO_SABOTAGE:
			if _sabotage_target_broken(senses):
				_decide(senses, rng)
			elif senses.arrived:
				_enter(State.SABOTAGE)
		State.SABOTAGE:
			if _advance(delta, _config.sabotage_seconds):
				_enter(State.LEAVE)
				return Effect.DAMAGE_GENERATOR if sabotage_generator else Effect.DAMAGE_HOSE
		State.GO_TRAPDOOR:
			if senses.arrived and senses.trapdoor_state != Trapdoor.State.CLOSED:
				_force_chase()
			elif senses.arrived:
				_enter(State.BANG_TRAPDOOR)
		State.BANG_TRAPDOOR:
			if senses.trapdoor_state != Trapdoor.State.CLOSED:
				_force_chase()
			elif _advance(delta, _config.bang_seconds):
				_enter(State.LEAVE)
		State.LEAVE:
			if senses.arrived:
				_enter(State.GONE)
	return Effect.NONE


func to_dict() -> Dictionary:
	return {
		"state": state,
		"sabotage_generator": sabotage_generator,
		"timer": _timer,
		"resume_state": _resume_state,
		"forced_chase": _forced_chase,
	}


func from_dict(data: Dictionary) -> void:
	var saved_state: int = data.get("state", State.APPROACH_DOOR)
	var saved_resume: int = data.get("resume_state", State.LEAVE)
	state = saved_state as State
	_resume_state = saved_resume as State
	sabotage_generator = data.get("sabotage_generator", false)
	_timer = data.get("timer", 0.0)
	_forced_chase = data.get("forced_chase", false)


func _update_chase(senses: DrownedSenses) -> Effect:
	if senses.player_in_kill_range:
		_enter(State.LEAVE)
		return Effect.KILL
	if not senses.player_in_reach and not _forced_chase:
		# Volta a andar até o alvo da ação que fazia; o progresso dela recomeça.
		_enter(_walking_state_for(_resume_state))
	return Effect.NONE


func _decide(senses: DrownedSenses, rng: RandomNumberGenerator) -> void:
	if senses.threat >= _threat_config.chase_threat_threshold:
		_enter(State.GO_TRAPDOOR)
		return
	if senses.hose_broken and senses.generator_broken:
		_enter(State.LEAVE)
		return
	if senses.generator_broken:
		sabotage_generator = false
	elif senses.hose_broken:
		sabotage_generator = true
	else:
		sabotage_generator = ThreatRules.prefers_generator(senses.threat, _threat_config, rng)
	_enter(State.GO_SABOTAGE)


func _sabotage_target_broken(senses: DrownedSenses) -> bool:
	return senses.generator_broken if sabotage_generator else senses.hose_broken


func _walking_state_for(previous: State) -> State:
	match previous:
		State.BREAK_DOOR:
			return State.APPROACH_DOOR
		State.SABOTAGE:
			return State.GO_SABOTAGE
		State.BANG_TRAPDOOR:
			return State.GO_TRAPDOOR
	return previous


func _force_chase() -> void:
	_forced_chase = true
	_enter(State.CHASE)


func _advance(delta: float, duration: float) -> bool:
	_timer += delta
	return _timer >= duration


func _enter(new_state: State) -> void:
	state = new_state
	_timer = 0.0
