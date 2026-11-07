class_name JerrycanState
extends RefCounted
## Galão: enche aos poucos no slot do tanque e despeja no gerador de emergência
## (decisão 0017). Começa a noite cheio.

var capacity: float
var amount: float


## Cria o galão cheio, com a capacidade dada.
func _init(jerrycan_capacity: float) -> void:
	capacity = jerrycan_capacity
	amount = capacity


## Enche no slot: vazio a cheio em `fill_seconds`.
func refill(delta: float, fill_seconds: float) -> void:
	if fill_seconds <= 0.0:
		amount = capacity
		return
	amount = minf(capacity, amount + capacity / fill_seconds * delta)


## Despeja no gerador o que ele aceitar; o que sobrar fica no galão.
func pour_into(generator: GeneratorState) -> float:
	var poured: float = generator.add_fuel(amount)
	amount -= poured
	return poured


## Devolve o nível de 0 a 1. Sem capacidade, devolve 0.
func ratio() -> float:
	if capacity <= 0.0:
		return 0.0
	return amount / capacity
