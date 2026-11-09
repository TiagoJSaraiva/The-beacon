class_name MonitorChannels
extends RefCounted
## Canais de um monitor: qual está aberto e a troca para o próximo, que volta ao primeiro depois
## do último.

var count: int
var current: int = 0


## Cria os canais com o primeiro aberto. Sem canais, fica sempre em 0.
func _init(channel_count: int) -> void:
	count = maxi(channel_count, 0)


## Abre o próximo canal (depois do último, o primeiro) e devolve o canal aberto.
func next() -> int:
	if count > 0:
		current = (current + 1) % count
	return current
