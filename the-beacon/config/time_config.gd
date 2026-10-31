class_name TimeConfig
extends Resource
## Duração e horário das noites (GDD 1.1 e 12.1).

@export_range(0, 23) var night_start_hour: int = 20
@export_range(0, 23) var night_end_hour: int = 6
## Segundos reais que valem uma hora do jogo. 90 s → noite de 20h a 6h em 15 min.
@export var real_seconds_per_game_hour: float = 90.0
