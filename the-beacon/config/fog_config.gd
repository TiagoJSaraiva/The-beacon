class_name FogConfig
extends Resource
## Nevoeiro (GDD 1.2.10). Intensidade vai de 0 (sem nevoeiro) a 1 (máxima).

@export var min_duration_seconds: float = 90.0
@export var max_duration_seconds: float = 240.0
@export_range(0.0, 1.0, 0.01) var min_intensity: float = 0.2
@export_range(0.0, 1.0, 0.01) var max_intensity: float = 1.0
## Quanto a intensidade pode variar por segundo enquanto o nevoeiro está presente.
@export var intensity_change_per_second: float = 0.02
## Intervalo entre sorteios de um novo alvo de intensidade.
@export var retarget_interval_seconds: float = 15.0
## A partir desta intensidade o nevoeiro cobre a câmera do farol e surge o Homem de Nevoeiro.
@export_range(0.0, 1.0, 0.01) var fog_man_threshold: float = 0.85
