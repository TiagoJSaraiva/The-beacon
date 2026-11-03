class_name BoatPassage
extends RefCounted
## Travessia de um barco (entrega 2). Cruza a rota em `crossing_seconds`. Dentro do trecho
## de nevoeiro sem ter desviado, afunda na hora. Com nevoeiro, chama pelo rádio até ser
## atendido; atendido com o feixe aceso, para e desvia.

enum Outcome { CROSSING, PASSED, SANK, DIVERTED }

var crossing_seconds: float
## Fração da rota percorrida (0 a 1).
var progress: float = 0.0
var outcome: Outcome = Outcome.CROSSING
var answered: bool = false


func _init(seconds_to_cross: float) -> void:
	crossing_seconds = seconds_to_cross


## `fog_start` e `fog_end`: trecho da rota coberto; iguais quando não há nevoeiro.
func tick(delta: float, fog_start: float, fog_end: float) -> void:
	if outcome != Outcome.CROSSING:
		return
	progress = minf(1.0, progress + delta / crossing_seconds)
	if _has_fog(fog_start, fog_end) and progress >= fog_start and progress <= fog_end:
		outcome = Outcome.SANK
	elif progress >= 1.0:
		outcome = Outcome.PASSED


## Precisa de aviso: há nevoeiro adiante e ninguém atendeu ainda.
func is_calling(fog_start: float, fog_end: float) -> bool:
	return (
		outcome == Outcome.CROSSING
		and not answered
		and _has_fog(fog_start, fog_end)
		and progress < fog_start
	)


## Rádio atendido. Com o feixe aceso, o barco desvia; apagado, segue em frente.
func answer(beam_lit: bool) -> void:
	answered = true
	if beam_lit and outcome == Outcome.CROSSING:
		outcome = Outcome.DIVERTED


func _has_fog(fog_start: float, fog_end: float) -> bool:
	return fog_end > fog_start
