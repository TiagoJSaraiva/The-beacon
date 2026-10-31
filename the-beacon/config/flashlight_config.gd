class_name FlashlightConfig
extends Resource
## Lanterna pessoal (GDD 1.2.19).

## Tempo total de uso ligada no plantão inteiro. Não recarrega.
@export var battery_seconds: float = 900.0
## Alcance e abertura do cone usados para dissipar o Homem de Nevoeiro.
@export var beam_range: float = 12.0
@export_range(1.0, 90.0) var beam_half_angle_degrees: float = 18.0
