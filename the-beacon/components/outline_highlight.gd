class_name OutlineHighlight
extends Node
## Contorno de destaque do objeto em foco (GDD 1.2.21): enquanto o `Interactable` está em foco, a
## mesma condição em que a HUD mostra a tecla de interagir, coloca o material de contorno por
## cima das malhas do alvo. Não conhece o dono do objeto: só escuta o sinal do interativo.

const OUTLINE_MATERIAL: Material = preload("res://components/outline_overlay.tres")

## Interativo cujo foco acende o contorno.
@export var interactable: Interactable
## Nó do objeto que recebe o contorno: ele e todas as malhas abaixo dele. Costuma ser o modelo ou
## a peça do objeto, porque o interativo é só um volume de mira. Cuidado com malhas que não são
## sólidas (facho, vidro): fora do alvo.
@export var target: Node

var _meshes: Array[GeometryInstance3D] = []


## Guarda as malhas do alvo e liga ao interativo, começando sem contorno.
func _ready() -> void:
	if interactable == null or target == null:
		push_warning("%s: OutlineHighlight sem Interactable ou sem alvo." % get_path())
		return
	var root := target as GeometryInstance3D
	if root != null:
		_meshes.append(root)
	for node: Node in target.find_children("*", "GeometryInstance3D", true, false):
		_meshes.append(node as GeometryInstance3D)
	interactable.focus_changed.connect(_on_interactable_focus_changed)


## Põe o material de contorno nas malhas do alvo quando `on`, e o tira quando não.
func _apply(on: bool) -> void:
	for mesh: GeometryInstance3D in _meshes:
		mesh.material_overlay = OUTLINE_MATERIAL if on else null


## Acompanha o foco do interativo.
func _on_interactable_focus_changed(focused: bool) -> void:
	_apply(focused)
