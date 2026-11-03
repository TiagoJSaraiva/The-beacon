class_name PowerConfig
extends Resource
## Gerador de emergência e galão (decisão 0017). Combustível em unidades abstratas. O
## gerador principal não usa combustível: depende só da mangueira.

@export_group("Gerador de emergência")
@export var generator_capacity: float = 100.0
@export var generator_start_fuel: float = 100.0
## Gasto enquanto alimenta o farol com a alavanca ligada.
@export var generator_consumption_per_second: float = 0.12

@export_group("Galão")
@export var jerrycan_capacity: float = 25.0
## Tempo para o slot encher o galão de vazio a cheio.
@export var jerrycan_slot_fill_seconds: float = 120.0
@export var jerrycan_pour_seconds: float = 4.0
