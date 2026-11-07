class_name FlashlightBattery
extends RefCounted
## Bateria da lanterna: só gasta ligada e nunca recarrega (GDD 1.2.19).

var capacity_seconds: float
var remaining_seconds: float


## Cria a bateria cheia, com a capacidade em segundos de uso.
func _init(capacity: float) -> void:
	capacity_seconds = capacity
	remaining_seconds = capacity


## Gasta a bateria e diz se ainda resta carga.
func drain(delta: float) -> bool:
	remaining_seconds = maxf(0.0, remaining_seconds - delta)
	return not is_empty()


## Diz se a carga acabou.
func is_empty() -> bool:
	return remaining_seconds <= 0.0


## Devolve a carga de 0 a 1. Sem capacidade, devolve 0.
func ratio() -> float:
	if capacity_seconds <= 0.0:
		return 0.0
	return remaining_seconds / capacity_seconds
