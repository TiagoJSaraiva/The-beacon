class_name ProgressState
extends RefCounted
## Progresso permanente de desbloqueio (GDD 1.2.14): a primeira dificuldade do catálogo está
## sempre liberada e vencer uma libera a seguinte. Morrer ou apagar o save não desfaz nada.

var unlocked_ids: Array[StringName] = []


## Diz se a dificuldade está liberada: é a primeira do catálogo ou já foi desbloqueada.
func is_unlocked(difficulty_id: StringName, catalog: DifficultyCatalog) -> bool:
	if catalog.difficulties.is_empty():
		return false
	return catalog.difficulties[0].id == difficulty_id or unlocked_ids.has(difficulty_id)


## Registra a vitória e devolve o id liberado agora (vazio se nada mudou).
func register_victory(difficulty_id: StringName, catalog: DifficultyCatalog) -> StringName:
	var index: int = _index_of(difficulty_id, catalog)
	if index < 0 or index + 1 >= catalog.difficulties.size():
		return &""
	var next_id: StringName = catalog.difficulties[index + 1].id
	if unlocked_ids.has(next_id):
		return &""
	unlocked_ids.append(next_id)
	return next_id


## Devolve os ids liberados em tipos aceitos pelo JSON.
func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for difficulty_id: StringName in unlocked_ids:
		ids.append(String(difficulty_id))
	return {"unlocked": ids}


## Substitui os ids liberados pelos do arquivo.
func from_dict(data: Dictionary) -> void:
	unlocked_ids.clear()
	var saved: Array = data.get("unlocked", [])
	for difficulty_id: Variant in saved:
		unlocked_ids.append(StringName(str(difficulty_id)))


## Devolve a posição da dificuldade no catálogo, ou -1 se ela não estiver lá.
func _index_of(difficulty_id: StringName, catalog: DifficultyCatalog) -> int:
	for index in catalog.difficulties.size():
		if catalog.difficulties[index].id == difficulty_id:
			return index
	return -1
