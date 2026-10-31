class_name TrapdoorResistance
extends RefCounted
## Tempo de batidas que o alçapão aguenta (GDD 1.2.11): corre enquanto batem sem o trinco,
## congela com o trinco seguro, não zera ao soltar e volta ao máximo quando vão embora.

var max_seconds: float
var remaining_seconds: float


func _init(resistance_seconds: float) -> void:
	max_seconds = resistance_seconds
	remaining_seconds = resistance_seconds


## Avança o tempo e diz se o alçapão quebrou.
func tick(delta: float, banging: bool, latched: bool) -> bool:
	if banging and not latched:
		remaining_seconds = maxf(0.0, remaining_seconds - delta)
	return remaining_seconds <= 0.0


func reset() -> void:
	remaining_seconds = max_seconds


func to_dict() -> Dictionary:
	return {"remaining_seconds": remaining_seconds}


func from_dict(data: Dictionary) -> void:
	var saved: float = data.get("remaining_seconds", max_seconds)
	remaining_seconds = clampf(saved, 0.0, max_seconds)
