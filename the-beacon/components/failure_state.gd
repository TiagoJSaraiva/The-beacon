class_name FailureState
extends RefCounted
## Peça que quebra ao acaso e tem conserto (lâmpada, casa de máquinas). Depois do conserto,
## só pode quebrar de novo passado `cooldown_seconds`.

var cooldown_seconds: float
var is_broken: bool = false

var _cooldown_left: float = 0.0


func _init(cooldown: float = 0.0) -> void:
	cooldown_seconds = cooldown


func can_break() -> bool:
	return not is_broken and _cooldown_left <= 0.0


func break_down() -> void:
	is_broken = true


func repair() -> void:
	is_broken = false
	_cooldown_left = cooldown_seconds


func tick(delta: float) -> void:
	if not is_broken:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
