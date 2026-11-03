class_name RunRequest
extends RefCounted
## Pedido de noite que o menu (ou a noite anterior) entrega à cena de jogo: a dificuldade e o
## plantão a continuar (decisão 0015).

var difficulty: DifficultyConfig
var run: RunState


func _init(chosen: DifficultyConfig, run_state: RunState) -> void:
	difficulty = chosen
	run = run_state
