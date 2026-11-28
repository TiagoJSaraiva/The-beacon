class_name FuelGauge
extends Node3D
## Medidor de combustível em barra, só de leitura (GDD 1.2.21: informação no cenário, sem HUD).
## Repete o nível de um gerador longe dele; não conhece o gerador: recebe o nível por método.

@onready var _fill_pivot: Node3D = %GaugePivot


## Enche a barra do medidor na proporção dada (0 a 1).
func show_fuel_ratio(ratio: float) -> void:
	# Escala zero deixa a malha degenerada; o mínimo mantém a barra invisível sem quebrar.
	_fill_pivot.scale.y = maxf(ratio, 0.001)
