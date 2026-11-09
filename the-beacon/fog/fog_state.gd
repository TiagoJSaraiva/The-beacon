class_name FogState
extends RefCounted
## Nevoeiro (entrega 2): um avanço de 0 a 1 que surge uma vez na noite e não vai mais embora.
## Fases:
## - CLEAR: ainda não surgiu. Surge pelo evento `fog` ou depois de `idle_grace_seconds` com o
##   farol parado.
## - PRESENT: com o farol parado, avança até 1. Quando o farol volta a operar, devolve de uma vez
##   `recoil_ratio` do que avançou nessa parada e, enquanto o farol opera, recua devagar a
##   `recede_per_second`, sem descer de `start_advance`. Com o feixe coberto (estágio BEAM), o
##   recuo de uma vez espera `unblock_seconds` de farol operando.

enum Phase { CLEAR, PRESENT }

var config: FogConfig
var phase: Phase = Phase.CLEAR
var advance: float = 0.0

var _idle_seconds: float = 0.0
## Verdadeiro desde que o farol parou até o recuo de uma vez ser aplicado.
var _expanding: bool = false
## Avanço quando a parada atual do farol começou; a diferença até o avanço atual é o que o recuo
## de uma vez devolve em parte.
var _expansion_start: float = 0.0
var _hold_left: float = 0.0


## Cria o nevoeiro em CLEAR, sem avanço, com a configuração dada.
func _init(fog_config: FogConfig) -> void:
	config = fog_config


## Diz se o nevoeiro pode surgir agora, ou seja, se ainda não surgiu nesta noite.
func can_start() -> bool:
	return phase == Phase.CLEAR


## Faz o nevoeiro surgir no mar em `start_advance`, se ainda não surgiu.
func start() -> void:
	if not can_start():
		return
	phase = Phase.PRESENT
	advance = config.start_advance


## Avança `delta` segundos conforme o farol opera ou não, pelas regras descritas na classe.
func tick(delta: float, operational: bool) -> void:
	_idle_seconds = 0.0 if operational else _idle_seconds + delta
	if phase == Phase.CLEAR:
		if operational or _idle_seconds < config.idle_grace_seconds:
			return
		start()
	if operational:
		_tick_operating(delta)
	else:
		_tick_stopped(delta)


## Devolve o estágio do avanço atual.
func stage() -> FogStage.Stage:
	return FogStage.for_advance(advance, config)


## Diz se o avanço atual bloqueia o feixe.
func blocks_beam() -> bool:
	return FogStage.blocks_beam(stage())


## Devolve o trecho coberto da rota dos barcos, em fração da rota (início, fim), centrado em
## `route_center`. Cresce com o avanço até `max_route_coverage`, atingido em `near_advance`. Sem
## nevoeiro, é vazio.
func route_segment() -> Vector2:
	if advance <= 0.0:
		return Vector2.ZERO
	var growth: float = clampf(advance / config.near_advance, 0.0, 1.0)
	var half: float = config.max_route_coverage * growth * 0.5
	return Vector2(config.route_center - half, config.route_center + half)


## Farol parado: guarda onde a parada começou e avança até 1. A espera do feixe coberto recomeça.
func _tick_stopped(delta: float) -> void:
	if not _expanding:
		_expanding = true
		_expansion_start = advance
	_hold_left = config.unblock_seconds
	advance = minf(1.0, advance + config.advance_per_second * delta)


## Farol operando: aplica o recuo de uma vez depois de uma parada (esperando, se o feixe estiver
## coberto) e, sem recuo pendente, recua devagar até `start_advance`.
func _tick_operating(delta: float) -> void:
	if _expanding:
		if blocks_beam() and _hold_left > 0.0:
			_hold_left -= delta
			return
		_expanding = false
		advance -= config.recoil_ratio * (advance - _expansion_start)
		return
	advance = maxf(config.start_advance, advance - config.recede_per_second * delta)
