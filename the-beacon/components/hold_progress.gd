class_name HoldProgress
extends RefCounted
## Progresso de uma interação de duração. Soltar a tecla zera tudo (GDD 1.2.21).

var duration: float
var elapsed: float = 0.0


func _init(hold_duration: float) -> void:
	duration = hold_duration


## Avança o progresso e diz se completou.
func advance(delta: float) -> bool:
	elapsed = minf(elapsed + delta, duration)
	return is_complete()


func is_complete() -> bool:
	return elapsed >= duration


func ratio() -> float:
	if duration <= 0.0:
		return 1.0
	return elapsed / duration


func reset() -> void:
	elapsed = 0.0
