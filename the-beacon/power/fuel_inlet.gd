class_name FuelInlet
extends Node3D
## Boca de combustível do gerador abastecido com o galão: medidor do nível, tampa e ponto onde
## o jogador despeja o galão segurando E. Não conhece o gerador: recebe o nível e avisa o despejo.

## O jogador completou a barra de despejo na boca.
signal pour_completed

@onready var _gauge_pivot: Node3D = %GaugePivot
@onready var _pour_point: Interactable = %PourPoint


## Enche a barra do medidor na proporção dada (0 a 1).
func show_fuel_ratio(ratio: float) -> void:
	# Escala zero deixa a malha degenerada; o mínimo mantém a barra invisível sem quebrar.
	_gauge_pivot.scale.y = maxf(ratio, 0.001)


## Define quanto tempo o jogador segura E para despejar o galão.
func set_pour_seconds(seconds: float) -> void:
	_pour_point.hold_seconds = seconds


## Avisa o despejo ao completar a barra.
func _on_pour_point_hold_completed() -> void:
	pour_completed.emit()
