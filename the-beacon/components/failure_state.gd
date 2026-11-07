class_name FailureState
extends RefCounted
## Peça que quebra ao acaso e tem conserto (lâmpada, casa de máquinas). Depois do conserto,
## só pode quebrar de novo passado `cooldown_seconds`.

var cooldown_seconds: float
var is_broken: bool = false

var _cooldown_left: float = 0.0


## Cria a peça inteira, com o intervalo mínimo entre um conserto e a próxima quebra.
func _init(cooldown: float = 0.0) -> void:
	cooldown_seconds = cooldown


## Diz se a peça está inteira e já passou do intervalo depois do último conserto.
func can_break() -> bool:
	return not is_broken and _cooldown_left <= 0.0


## Marca a peça como quebrada. Quem sorteia a quebra confere `can_break` antes.
func break_down() -> void:
	is_broken = true


## Conserta a peça e começa a contar o intervalo até ela poder quebrar de novo.
func repair() -> void:
	is_broken = false
	_cooldown_left = cooldown_seconds


## Desconta o intervalo. Com a peça quebrada, a contagem fica parada.
func tick(delta: float) -> void:
	if not is_broken:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
