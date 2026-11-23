class_name MonitorChannels
extends RefCounted
## Canais de um monitor: qual está aberto e a troca para o próximo, que volta ao primeiro depois
## do último. Diz também qual câmera precisa renderizar: só a do canal aberto, e só com o jogador
## no mesmo cômodo e a tela no enquadramento dele.

## Valor de `live_channel()` quando nenhuma câmera precisa renderizar.
const NO_CHANNEL := -1

var count: int
var current: int = 0
## Se a tela do monitor cabe no enquadramento de alguma câmera que renderiza (a do jogador, na
## prática). O teste de enquadramento não vê paredes nem pisos.
var on_screen: bool = false
## Se o jogador está no cômodo do monitor: tira do enquadramento o que paredes e pisos escondem.
var viewer_present: bool = false


## Cria os canais com o primeiro aberto. Sem canais, fica sempre em 0.
func _init(channel_count: int) -> void:
	count = maxi(channel_count, 0)


## Abre o próximo canal (depois do último, o primeiro) e devolve o canal aberto.
func next() -> int:
	if count > 0:
		current = (current + 1) % count
	return current


## Devolve o canal cuja câmera precisa renderizar: o aberto, com o jogador no cômodo e a tela no
## enquadramento; senão (ou sem canais), `NO_CHANNEL`. Câmera que ninguém vê não gasta a GPU.
func live_channel() -> int:
	if count == 0 or not on_screen or not viewer_present:
		return NO_CHANNEL
	return current
