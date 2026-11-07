class_name BatteryGauge
extends Node3D
## Barra de carga no corpo da lanterna. O preenchimento (`Fill`, do comprimento da barra
## cheia) encolhe em direção à ponta -X.

@export var length: float = 0.12

@onready var _fill: MeshInstance3D = $Fill


## Mostra a carga de 0 a 1 encolhendo o preenchimento. Valores fora da faixa são limitados; em
## zero, ele some.
func show_ratio(ratio: float) -> void:
	var clamped: float = clampf(ratio, 0.0, 1.0)
	# Escala zero deixa a transformação degenerada; vazia, a barra só some.
	_fill.visible = clamped > 0.0
	if not _fill.visible:
		return
	_fill.scale.x = clamped
	_fill.position.x = -length * (1.0 - clamped) * 0.5
