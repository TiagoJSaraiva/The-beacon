class_name HoldProgress
extends RefCounted
## Progresso de uma interação de duração. Soltar a tecla zera tudo (GDD 1.2.21).

var duration: float
var elapsed: float = 0.0


## Cria o progresso zerado, com a duração total em segundos.
func _init(hold_duration: float) -> void:
	duration = hold_duration


## Avança o progresso e diz se completou.
func advance(delta: float) -> bool:
	elapsed = minf(elapsed + delta, duration)
	return is_complete()


## Diz se o tempo segurando já chegou à duração.
func is_complete() -> bool:
	return elapsed >= duration


## Devolve o progresso de 0 a 1. Com duração zero, já está completo (1).
func ratio() -> float:
	if duration <= 0.0:
		return 1.0
	return elapsed / duration


## Zera o progresso.
func reset() -> void:
	elapsed = 0.0
