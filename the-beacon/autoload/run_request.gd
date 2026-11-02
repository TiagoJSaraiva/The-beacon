class_name RunRequest
extends RefCounted
## Pedido de partida que o menu entrega à cena de jogo: um plantão novo numa dificuldade
## ou a continuação do save.

## Dificuldade de um plantão novo. Nula ao continuar: o save diz qual é.
var difficulty: DifficultyConfig
## Save da partida a restaurar; vazio num plantão novo.
var saved_run: Dictionary = {}


func _init(chosen: DifficultyConfig, saved: Dictionary = {}) -> void:
	difficulty = chosen
	saved_run = saved
