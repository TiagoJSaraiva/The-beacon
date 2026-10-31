class_name GeneratorState
extends RefCounted
## Combustível e quebra do gerador (GDD 1.2.5). Funciona com combustível e sem quebra.

var config: PowerConfig
var fuel: float
var is_broken: bool = false
## Feixe do farol aceso: soma o consumo extra.
var beam_load: bool = false


func _init(power_config: PowerConfig) -> void:
	config = power_config
	fuel = clampf(config.generator_start_fuel, 0.0, config.generator_capacity)


func is_running() -> bool:
	return fuel > 0.0 and not is_broken


func consumption_per_second() -> float:
	var extra: float = config.beam_extra_consumption_per_second if beam_load else 0.0
	return config.generator_consumption_per_second + extra


func tick(delta: float) -> void:
	if not is_running():
		return
	fuel = maxf(0.0, fuel - consumption_per_second() * delta)


## Põe combustível até a capacidade e devolve quanto foi aceito.
func add_fuel(amount: float) -> float:
	var accepted: float = clampf(amount, 0.0, config.generator_capacity - fuel)
	fuel += accepted
	return accepted


func fuel_ratio() -> float:
	return fuel / config.generator_capacity


func to_dict() -> Dictionary:
	return {"fuel": fuel, "is_broken": is_broken}


func from_dict(data: Dictionary) -> void:
	var saved_fuel: float = data.get("fuel", fuel)
	fuel = clampf(saved_fuel, 0.0, config.generator_capacity)
	is_broken = data.get("is_broken", false)
