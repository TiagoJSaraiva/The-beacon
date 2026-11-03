class_name BoatPassage
extends RefCounted
## Passagem de um barco pela ilha (GDD 1.2.26, provisório). A contagem até afundar começa
## quando o rádio toca e só anda com nevoeiro e feixe apagado; mais nevoeiro, mais rápido.
## Pirata não afunda; se o feixe acender durante a passagem, ele encontra o farol.

enum Outcome { PASSING, PASSED, SANK }

var config: BoatConfig
var is_pirate: bool
var elapsed_seconds: float = 0.0
## De 0 a 1; em 1 o barco afunda.
var sink_progress: float = 0.0
var outcome: Outcome = Outcome.PASSING
var was_answered: bool = false
var pirate_guided: bool = false


func _init(boat_config: BoatConfig, pirate: bool) -> void:
	config = boat_config
	is_pirate = pirate


## Segundos de feixe apagado até afundar na intensidade dada (0 a 1).
static func sink_seconds(fog_intensity: float, boat_config: BoatConfig) -> float:
	return lerpf(
		boat_config.sink_seconds_at_min_intensity,
		boat_config.sink_seconds_at_max_intensity,
		clampf(fog_intensity, 0.0, 1.0)
	)


func tick(delta: float, fog_intensity: float, beam_active: bool) -> void:
	if outcome != Outcome.PASSING:
		return
	elapsed_seconds += delta
	if is_pirate:
		pirate_guided = pirate_guided or beam_active
	elif fog_intensity > 0.0 and not beam_active:
		sink_progress += delta / sink_seconds(fog_intensity, config)
		if sink_progress >= 1.0:
			outcome = Outcome.SANK
			return
	if elapsed_seconds >= config.passage_seconds:
		outcome = Outcome.PASSED


## Fração da rota já percorrida (0 a 1).
func route_progress() -> float:
	return clampf(elapsed_seconds / config.passage_seconds, 0.0, 1.0)
