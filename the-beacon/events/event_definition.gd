class_name EventDefinition
extends Resource
## Evento sorteável da noite (falha, nevoeiro, barco).
## A janela usa horas do relógio do jogo e pode cruzar a meia-noite (ex.: 22 → 4).
## Quem trata o evento é o sistema que se registra no EventDirector com este recurso.

@export var id: StringName = &""
@export_range(0.0, 24.0, 0.25) var window_start_hour: float = 20.0
@export_range(0.0, 24.0, 0.25) var window_end_hour: float = 6.0
## Intervalo, em segundos reais, entre duas tentativas de sorteio.
@export var check_interval_seconds: float = 30.0
## Chance de disparar em cada tentativa, antes dos multiplicadores de dificuldade e noite.
@export_range(0.0, 1.0, 0.01) var chance_per_check: float = 0.1
## Limite de disparos numa mesma noite. 0 = sem limite.
@export var max_per_night: int = 1
