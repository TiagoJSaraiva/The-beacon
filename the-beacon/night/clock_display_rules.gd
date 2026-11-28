class_name ClockDisplayRules
extends RefCounted
## Horário que o relógio de parede mostra. Fora da vista do jogador, é o horário do jogo. Enquanto
## o jogador o vê, o visor corre em tempo real (1 minuto do visor a cada `seconds_per_minute`
## segundos reais, bem mais devagar que a noite) e só alcança o horário do jogo quando o jogador
## desvia o olhar. Os minutos contam desde o meio-dia, para a virada da meia-noite seguir em frente.

const MINUTES_PER_HOUR := 60
const HOURS_PER_DAY := 24
const NOON_HOUR := 12

var _seconds_per_minute: float
var _game_minutes: int = 20 * MINUTES_PER_HOUR
var _frozen_minutes: int = 0
var _looked_seconds: float = 0.0
var _was_looking: bool = false


## Cria a regra com o ritmo do visor visto: `seconds_per_minute` segundos reais por minuto dele.
func _init(seconds_per_minute: float = 60.0) -> void:
	_seconds_per_minute = maxf(seconds_per_minute, 0.001)


## Converte um horário `HH:MM` em minutos desde o meio-dia: 20:00 → 480, 00:30 → 750, 06:00 → 1080.
static func to_minutes(text: String) -> int:
	var parts: PackedStringArray = text.split(":")
	var hour: int = parts[0].to_int()
	var minute: int = parts[1].to_int() if parts.size() > 1 else 0
	if hour < NOON_HOUR:
		hour += HOURS_PER_DAY
	return (hour - NOON_HOUR) * MINUTES_PER_HOUR + minute


## Converte minutos desde o meio-dia em `HH:MM`.
static func to_text(minutes: int) -> String:
	var total: int = minutes + NOON_HOUR * MINUTES_PER_HOUR
	@warning_ignore("integer_division")
	var hour: int = (total / MINUTES_PER_HOUR) % HOURS_PER_DAY
	return "%02d:%02d" % [hour, total % MINUTES_PER_HOUR]


## Guarda o horário do jogo (`HH:MM`), que o visor alcança quando ninguém o olha.
func set_game_time(text: String) -> void:
	_game_minutes = to_minutes(text)


## Avança `delta` segundos reais e devolve o texto a mostrar. Ao começar a olhar, congela o visor
## no horário daquele instante; o visor nunca passa do horário do jogo.
func advance(delta: float, looking: bool) -> String:
	if not looking:
		_was_looking = false
		return to_text(_game_minutes)
	if not _was_looking:
		_was_looking = true
		_frozen_minutes = _game_minutes
		_looked_seconds = 0.0
	_looked_seconds += delta
	var shown: int = _frozen_minutes + int(_looked_seconds / _seconds_per_minute)
	return to_text(mini(shown, _game_minutes))
