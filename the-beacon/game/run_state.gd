class_name RunState
extends RefCounted
## Plantão em andamento: dificuldade e noite atual (GDD 1.2.1). Vence quem sobrevive à
## última noite, qualquer que seja o estado do farol.

var difficulty_id: StringName
var total_nights: int
var current_night: int = 1


func _init(difficulty: StringName, nights: int) -> void:
	difficulty_id = difficulty
	total_nights = nights


func is_last_night() -> bool:
	return current_night >= total_nights


func advance_night() -> void:
	current_night = mini(current_night + 1, total_nights)


func to_dict() -> Dictionary:
	return {
		"difficulty_id": String(difficulty_id),
		"total_nights": total_nights,
		"current_night": current_night,
	}


func from_dict(data: Dictionary) -> void:
	difficulty_id = StringName(data.get("difficulty_id", String(difficulty_id)))
	total_nights = data.get("total_nights", total_nights)
	current_night = clampi(data.get("current_night", 1), 1, total_nights)
