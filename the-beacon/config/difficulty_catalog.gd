class_name DifficultyCatalog
extends Resource
## Dificuldades na ordem de desbloqueio: cada uma libera ao vencer a anterior (GDD 1.2.14).

@export var difficulties: Array[DifficultyConfig] = []


func find_by_id(difficulty_id: StringName) -> DifficultyConfig:
	for difficulty: DifficultyConfig in difficulties:
		if difficulty.id == difficulty_id:
			return difficulty
	return null
