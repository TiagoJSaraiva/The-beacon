class_name BeamState
extends RefCounted
## Estado do farol. Operando = alavanca ligada + energia + lâmpada inteira + casa de
## máquinas inteira. Aceso = operando + nevoeiro sem bloquear o feixe.

var switch_on: bool = false
var powered: bool = true
var lamp_burned: bool = false
var machine_broken: bool = false
var fog_blocking: bool = false


## Diz se o farol está operando: alavanca ligada, com energia, lâmpada e casa de máquinas
## inteiras.
func is_operational() -> bool:
	return switch_on and powered and not lamp_burned and not machine_broken


## Diz se o feixe está aceso: farol operando e nevoeiro sem bloquear.
func is_lit() -> bool:
	return is_operational() and not fog_blocking
