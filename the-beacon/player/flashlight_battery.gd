class_name FlashlightBattery
extends RefCounted
## Bateria da lanterna: só gasta ligada e nunca recarrega (GDD 1.2.19).

var capacity_seconds: float
var remaining_seconds: float


func _init(capacity: float) -> void:
	capacity_seconds = capacity
	remaining_seconds = capacity


## Gasta a bateria e diz se ainda resta carga.
func drain(delta: float) -> bool:
	remaining_seconds = maxf(0.0, remaining_seconds - delta)
	return not is_empty()


func is_empty() -> bool:
	return remaining_seconds <= 0.0


func ratio() -> float:
	if capacity_seconds <= 0.0:
		return 0.0
	return remaining_seconds / capacity_seconds


func to_dict() -> Dictionary:
	return {"remaining_seconds": remaining_seconds}


func from_dict(data: Dictionary) -> void:
	var saved: float = data.get("remaining_seconds", capacity_seconds)
	remaining_seconds = clampf(saved, 0.0, capacity_seconds)
