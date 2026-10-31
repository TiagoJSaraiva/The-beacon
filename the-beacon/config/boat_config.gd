class_name BoatConfig
extends Resource
## Barcos e rádio (GDD 1.2.26).

## Tempo que o barco leva para passar pela ilha, contado a partir do toque do rádio.
@export var passage_seconds: float = 120.0
@export_range(0.0, 1.0, 0.01) var pirate_chance: float = 0.25
## Tempo de feixe desligado, no nevoeiro mais fraco, até o barco afundar.
@export var sink_seconds_at_min_intensity: float = 90.0
## Mesmo tempo no nevoeiro mais forte.
@export var sink_seconds_at_max_intensity: float = 30.0
