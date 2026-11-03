class_name BeamState
extends RefCounted
## Estado do farol. Operando = alavanca ligada + energia + lâmpada inteira + casa de
## máquinas inteira. Aceso = operando + nevoeiro sem bloquear o feixe.

var switch_on: bool = false
var powered: bool = true
var lamp_burned: bool = false
var machine_broken: bool = false
var fog_blocking: bool = false


func is_operational() -> bool:
	return switch_on and powered and not lamp_burned and not machine_broken


func is_lit() -> bool:
	return is_operational() and not fog_blocking
