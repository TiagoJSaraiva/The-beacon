class_name PowerConsumer
extends Node
## Elemento alimentado pelo gerador (GDD 16.3): repassa ao dono cada mudança de energia.
## Novo elemento alimentado = este nó + uma conexão na cena, sem mexer no gerador.

signal powered_changed(powered: bool)

@export var source: Generator

var is_powered: bool = false


func _ready() -> void:
	if source == null:
		push_warning("PowerConsumer sem source atribuído")
		return
	source.power_changed.connect(_on_source_power_changed)
	# Espera o dono ficar pronto antes de informar o estado inicial.
	_on_source_power_changed.call_deferred(source.is_running())


func _on_source_power_changed(powered: bool) -> void:
	is_powered = powered
	powered_changed.emit(powered)
