class_name OutlineHighlight
extends Node
## Contorno de destaque do objeto em foco (GDD 1.2.21): enquanto o `Interactable` está em foco, a
## mesma condição em que a HUD mostra a tecla de interagir, coloca o material de contorno por
## cima das malhas-alvo. Não conhece o dono do objeto: só escuta o sinal do interativo.

const OUTLINE_MATERIAL: Material = preload("res://components/outline_overlay.tres")

## Interativo cujo foco acende o contorno.
@export var interactable: Interactable
## Malhas que recebem o contorno. Costumam ser as do próprio objeto, porque o interativo é só um
## volume de mira.
@export var targets: Array[GeometryInstance3D] = []


## Liga ao interativo e começa sem contorno.
func _ready() -> void:
	if interactable == null:
		push_warning("%s: OutlineHighlight sem Interactable." % get_path())
		return
	interactable.focus_changed.connect(_on_interactable_focus_changed)
	_apply(false)


## Põe o material de contorno nas malhas-alvo quando `on`, e o tira quando não.
func _apply(on: bool) -> void:
	for target: GeometryInstance3D in targets:
		if target != null:
			target.material_overlay = OUTLINE_MATERIAL if on else null


## Acompanha o foco do interativo.
func _on_interactable_focus_changed(focused: bool) -> void:
	_apply(focused)
