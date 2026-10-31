class_name PowerConfig
extends Resource
## Gerador, tanque de reserva e galão (GDD 1.2.5). Combustível em unidades abstratas.

@export_group("Gerador")
@export var generator_capacity: float = 100.0
@export var generator_start_fuel: float = 100.0
@export var generator_consumption_per_second: float = 0.06
## Consumo somado enquanto o feixe está de fato aceso.
@export var beam_extra_consumption_per_second: float = 0.06

@export_group("Reserva")
## Combustível total do plantão inteiro: não é reabastecido entre noites.
@export var reserve_capacity: float = 300.0
@export var reserve_start_fuel: float = 300.0
## Vazamento enquanto a mangueira está rompida.
@export var reserve_leak_per_second: float = 0.2

@export_group("Galão")
@export var jerrycan_capacity: float = 25.0
@export var jerrycan_fill_seconds: float = 4.0
@export var jerrycan_pour_seconds: float = 4.0
