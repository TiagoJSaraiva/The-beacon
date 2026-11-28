class_name PoweredLights
extends Node3D
## Grupo de luzes que depende de uma fonte de energia: sem energia, todas as `Light3D` abaixo
## deste nó apagam. Quem decide a fonte é o dono, por `set_powered` (estado de funcionamento
## trocado por sinal, GDD 16.3). Não mexe na energia das luzes: isso é do `InteriorLights`.

var _powered: bool = true


## Guarda o estado e acende ou apaga as luzes abaixo deste nó.
func set_powered(powered: bool) -> void:
	_powered = powered
	for node: Node in find_children("*", "Light3D", true, false):
		(node as Light3D).visible = powered


## Diz se o grupo está com energia.
func is_powered() -> bool:
	return _powered
