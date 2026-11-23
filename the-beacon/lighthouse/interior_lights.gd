class_name InteriorLights
extends Node3D
## Luzes das luminárias do farol (todas as `Light3D` abaixo deste nó, inclusive dentro das cenas
## instanciadas): multiplica a energia de cada uma por `light_scale`, sem perder a da cena.

## Força das luzes do interior: 1 é a energia que cada luminária tem na própria cena.
@export_range(0.0, 2.0, 0.05) var light_scale: float = 0.4:
	set(value):
		light_scale = value
		_apply()

## Energia de cada luz como está na cena, antes da escala.
var _base_energy: Dictionary[Light3D, float] = {}


## Guarda a energia de cada luz abaixo deste nó e aplica a escala.
func _ready() -> void:
	for node: Node in find_children("*", "Light3D", true, false):
		var light := node as Light3D
		_base_energy[light] = light.light_energy
	_apply()


## Aplica `light_scale` à energia guardada de cada luz. Antes do `_ready`, não há luz guardada.
func _apply() -> void:
	for light: Light3D in _base_energy:
		light.light_energy = _base_energy[light] * light_scale
