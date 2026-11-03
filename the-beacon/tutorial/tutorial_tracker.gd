class_name TutorialTracker
extends RefCounted
## Quais passos do tutorial já apareceram (GDD 9.1): cada um só na primeira vez que a
## situação acontece; o tutorial termina quando todos apareceram.

var step_ids: Array[StringName] = []
var shown_ids: Array[StringName] = []


func _init(ids: Array[StringName]) -> void:
	step_ids = ids


## Marca o passo como mostrado e diz se é a primeira vez (só então o texto deve aparecer).
func mark_shown(step_id: StringName) -> bool:
	if not step_ids.has(step_id) or shown_ids.has(step_id):
		return false
	shown_ids.append(step_id)
	return true


func is_finished() -> bool:
	return shown_ids.size() >= step_ids.size()


## Retoma os passos mostrados em noites anteriores. Ids que não existem mais no conteúdo
## são descartados.
func restore(ids: Array[StringName]) -> void:
	shown_ids.clear()
	for step_id: StringName in ids:
		if step_ids.has(step_id) and not shown_ids.has(step_id):
			shown_ids.append(step_id)
