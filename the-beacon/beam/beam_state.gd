class_name BeamState
extends RefCounted
## Feixe do farol (GDD 1.2.7): aceso só com interruptor ligado, energia e lâmpada inteira.

var switch_on: bool = false
var powered: bool = true
var lamp_burned: bool = false


func is_active() -> bool:
	return switch_on and powered and not lamp_burned
