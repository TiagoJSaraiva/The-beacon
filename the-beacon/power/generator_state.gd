class_name GeneratorState
extends RefCounted
## Gerador (decisão 0017). Pela mangueira (`HOSE`): funciona enquanto ela está inteira e não
## gasta nada. Por combustível (`FUEL`): funciona enquanto tem combustível e só gasta em uso.

enum Feed { HOSE, FUEL }

var config: PowerConfig
var feed: Feed
var fuel: float = 0.0
var hose_intact: bool = true
## Alimentando o farol ligado. Só em uso o gerador por combustível gasta.
var in_use: bool = false


func _init(power_config: PowerConfig, generator_feed: Feed = Feed.FUEL) -> void:
	config = power_config
	feed = generator_feed
	if feed == Feed.FUEL:
		fuel = clampf(config.generator_start_fuel, 0.0, config.generator_capacity)


func is_running() -> bool:
	if feed == Feed.HOSE:
		return hose_intact
	return fuel > 0.0


func tick(delta: float) -> void:
	if feed == Feed.FUEL and in_use:
		fuel = maxf(0.0, fuel - config.generator_consumption_per_second * delta)


## Põe combustível até a capacidade e devolve quanto foi aceito. Pela mangueira, nada.
func add_fuel(amount: float) -> float:
	if feed == Feed.HOSE:
		return 0.0
	var accepted: float = clampf(amount, 0.0, config.generator_capacity - fuel)
	fuel += accepted
	return accepted


func fuel_ratio() -> float:
	if feed == Feed.HOSE or config.generator_capacity <= 0.0:
		return 0.0
	return fuel / config.generator_capacity
