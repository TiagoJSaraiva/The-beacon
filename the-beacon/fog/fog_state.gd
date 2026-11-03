class_name FogState
extends RefCounted
## Nevoeiro (entrega 2): um avanço de 0 a 1 que cresce com o farol parado e recua com ele
## operando. Fases:
## - CLEAR: sem nevoeiro (ou se dissipando). Surge pelo evento `fog` ou depois de
##   `idle_grace_seconds` com o farol parado.
## - SEA: no mar, se adensa até `sea_max_advance`; ao fim da duração sorteada, dissipa.
## - ADVANCING: farol parado; avança até 1.
## - HOLDING: o farol voltou a operar com o nevoeiro perto; ainda bloqueia por
##   `unblock_seconds`.
## - RECEDING: recua até `recede_to_advance` e volta ao mar.

enum Phase { CLEAR, SEA, ADVANCING, HOLDING, RECEDING }

var config: FogConfig
var phase: Phase = Phase.CLEAR
var advance: float = 0.0
var remaining_seconds: float = 0.0
## Centro do trecho coberto da rota dos barcos (0 a 1), sorteado ao surgir.
var route_center: float = 0.5

var _idle_seconds: float = 0.0
var _hold_left: float = 0.0


func _init(fog_config: FogConfig) -> void:
	config = fog_config


func can_start() -> bool:
	return phase == Phase.CLEAR


## Surge no mar.
func start(rng: RandomNumberGenerator) -> void:
	if not can_start():
		return
	phase = Phase.SEA
	advance = maxf(advance, config.start_advance)
	remaining_seconds = rng.randf_range(config.min_duration_seconds, config.max_duration_seconds)
	var half_coverage: float = config.max_route_coverage * 0.5
	route_center = rng.randf_range(half_coverage, 1.0 - half_coverage)


func tick(delta: float, operational: bool, rng: RandomNumberGenerator) -> void:
	_idle_seconds = 0.0 if operational else _idle_seconds + delta
	if phase == Phase.CLEAR:
		if operational or _idle_seconds < config.idle_grace_seconds:
			advance = move_toward(advance, 0.0, config.recede_per_second * delta)
			return
		start(rng)
	if not operational:
		phase = Phase.ADVANCING
	match phase:
		Phase.ADVANCING:
			if not operational:
				advance = minf(1.0, advance + config.advance_per_second * delta)
			elif blocks_beam():
				phase = Phase.HOLDING
				_hold_left = config.unblock_seconds
			else:
				phase = Phase.SEA
		Phase.HOLDING:
			_hold_left -= delta
			if _hold_left <= 0.0:
				phase = Phase.RECEDING
		Phase.RECEDING:
			advance = move_toward(
				advance, config.recede_to_advance, config.recede_per_second * delta
			)
			if advance <= config.recede_to_advance:
				phase = Phase.SEA
		Phase.SEA:
			remaining_seconds -= delta
			if remaining_seconds <= 0.0:
				phase = Phase.CLEAR
			elif advance < config.sea_max_advance:
				advance = minf(
					config.sea_max_advance, advance + config.sea_densify_per_second * delta
				)


func stage() -> FogStage.Stage:
	return FogStage.for_advance(advance, config)


func blocks_beam() -> bool:
	return FogStage.blocks_beam(stage())


## Trecho coberto da rota dos barcos, em fração da rota (início, fim). Cresce com o avanço
## até `max_route_coverage`, que é atingido em `near_advance`. Sem nevoeiro, vazio.
func route_segment() -> Vector2:
	if advance <= 0.0:
		return Vector2.ZERO
	var growth: float = clampf(advance / config.near_advance, 0.0, 1.0)
	var half: float = config.max_route_coverage * growth * 0.5
	return Vector2(route_center - half, route_center + half)
