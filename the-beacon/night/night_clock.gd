class_name NightClock
extends RefCounted
## Relógio de uma noite: converte segundos reais em horário do jogo (GDD 1.1).
## A noite cruza a meia-noite (20h → 6h), então horas são tratadas em módulo 24.

const HOURS_PER_DAY := 24.0
const MINUTES_PER_HOUR := 60

var config: TimeConfig
var elapsed_seconds: float = 0.0


func _init(time_config: TimeConfig) -> void:
	config = time_config


## Diz se a hora do relógio (0–24) está na janela [start, end), que pode cruzar a meia-noite.
static func is_hour_in_window(hour: float, window_start: float, window_end: float) -> bool:
	if window_start <= window_end:
		return hour >= window_start and hour < window_end
	return hour >= window_start or hour < window_end


func night_length_hours() -> float:
	return fposmod(float(config.night_end_hour - config.night_start_hour), HOURS_PER_DAY)


func duration_seconds() -> float:
	return night_length_hours() * config.real_seconds_per_game_hour


## Avança o relógio e diz se a noite terminou.
func advance(delta: float) -> bool:
	elapsed_seconds = minf(elapsed_seconds + delta, duration_seconds())
	return is_finished()


func is_finished() -> bool:
	return elapsed_seconds >= duration_seconds()


## Hora atual do relógio, de 0 a 24 (ex.: 23.5 = 23:30).
func clock_hour() -> float:
	var hours_elapsed: float = elapsed_seconds / config.real_seconds_per_game_hour
	return fposmod(config.night_start_hour + hours_elapsed, HOURS_PER_DAY)


## Horário no formato do relógio digital de parede.
func display_text() -> String:
	var total_minutes: int = floori(clock_hour() * MINUTES_PER_HOUR)
	@warning_ignore("integer_division")
	return "%02d:%02d" % [total_minutes / MINUTES_PER_HOUR, total_minutes % MINUTES_PER_HOUR]


func reset() -> void:
	elapsed_seconds = 0.0


func to_dict() -> Dictionary:
	return {"elapsed_seconds": elapsed_seconds}


func from_dict(data: Dictionary) -> void:
	var saved: float = data.get("elapsed_seconds", 0.0)
	elapsed_seconds = clampf(saved, 0.0, duration_seconds())
