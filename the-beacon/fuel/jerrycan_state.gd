class_name JerrycanState
extends RefCounted
## Galão: carrega uma quantidade fixa por vez da reserva até o gerador (GDD 1.2.5).

var capacity: float
var amount: float = 0.0
var is_carried: bool = false


func _init(jerrycan_capacity: float) -> void:
	capacity = jerrycan_capacity


## Enche até a capacidade com o que a reserva tiver e devolve quanto entrou.
func fill_from(reserve: ReserveTankState) -> float:
	var taken: float = reserve.draw(capacity - amount)
	amount += taken
	return taken


## Despeja no gerador o que ele aceitar; o que sobrar fica no galão.
func pour_into(generator: GeneratorState) -> float:
	var poured: float = generator.add_fuel(amount)
	amount -= poured
	return poured


func to_dict() -> Dictionary:
	return {"amount": amount, "is_carried": is_carried}


func from_dict(data: Dictionary) -> void:
	var saved_amount: float = data.get("amount", 0.0)
	amount = clampf(saved_amount, 0.0, capacity)
	is_carried = data.get("is_carried", false)
