class_name WallClock
extends Node3D
## Relógio digital fixo na parede (GDD 1.1). Funciona sem energia (decisão 0017, provisório).

@onready var _display: Label3D = %Display


## Mostra no visor o texto recebido, como `23:30`.
func show_time(text: String) -> void:
	_display.text = text
