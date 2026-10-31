class_name ReserveTankState
extends RefCounted
## Tanque de reserva do plantão inteiro (GDD 1.2.5). Com a mangueira rompida, vaza
## aos poucos e não enche o galão (GDD 1.2.25).

var config: PowerConfig
var fuel: float
var hose_broken: bool = false


func _init(power_config: PowerConfig) -> void:
	config = power_config
	fuel = clampf(config.reserve_start_fuel, 0.0, config.reserve_capacity)


func tick(delta: float) -> void:
	if hose_broken:
		fuel = maxf(0.0, fuel - config.reserve_leak_per_second * delta)


func can_fill() -> bool:
	return not hose_broken and fuel > 0.0


## Retira até `amount` de combustível e devolve quanto saiu.
func draw(amount: float) -> float:
	if not can_fill():
		return 0.0
	var taken: float = clampf(amount, 0.0, fuel)
	fuel -= taken
	return taken


func fuel_ratio() -> float:
	if config.reserve_capacity <= 0.0:
		return 0.0
	return fuel / config.reserve_capacity


func to_dict() -> Dictionary:
	return {"fuel": fuel, "hose_broken": hose_broken}


func from_dict(data: Dictionary) -> void:
	var saved_fuel: float = data.get("fuel", fuel)
	fuel = clampf(saved_fuel, 0.0, config.reserve_capacity)
	hose_broken = data.get("hose_broken", false)
