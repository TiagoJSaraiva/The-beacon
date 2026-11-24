class_name EventDirector
extends Node
## Roda o sorteio dos eventos enquanto a noite corre. Cada sistema registra os eventos
## que trata (decisão 0008); evento sem registro nunca dispara.

signal event_triggered(event_id: StringName)

@export var night: NightDirector

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Desligado, o sorteio para; `trigger_now` continua funcionando (painel de debug).
var random_events_enabled: bool = true

var _difficulty: DifficultyConfig
var _scheduler: EventScheduler = EventScheduler.new()
var _can_trigger: Dictionary[StringName, Callable] = {}
var _trigger: Dictionary[StringName, Callable] = {}


## Prepara o RNG. Sem `night` atribuído, avisa e desliga o sorteio.
func _ready() -> void:
	rng.randomize()
	if night == null:
		push_warning("EventDirector sem night atribuído")
		set_process(false)


## Roda o sorteio enquanto a noite corre e `random_events_enabled` está ligado, aciona quem
## trata cada evento sorteado e emite `event_triggered`.
func _process(delta: float) -> void:
	if _difficulty == null or not night.is_running or not random_events_enabled:
		return
	var fired: Array[EventDefinition] = _scheduler.update(
		delta, night.clock.clock_hour(), _difficulty.event_chance_multiplier, rng, _is_eligible
	)
	for definition: EventDefinition in fired:
		_trigger[definition.id].call()
		event_triggered.emit(definition.id)


## Guarda a dificuldade e recria o sorteio com os eventos dela. Os registros feitos em `register`
## são mantidos.
func configure(difficulty: DifficultyConfig) -> void:
	_difficulty = difficulty
	_scheduler = EventScheduler.new()
	for definition: EventDefinition in difficulty.events:
		_scheduler.add(definition)


## Registra quem trata o evento: `can_trigger() -> bool` e `trigger() -> void`.
func register(event_id: StringName, can_trigger: Callable, trigger: Callable) -> void:
	_can_trigger[event_id] = can_trigger
	_trigger[event_id] = trigger


## Dispara o evento agora, fora do sorteio e sem contar no máximo da noite, se o sistema que o
## trata aceitar. Devolve se disparou e, se sim, emite `event_triggered`.
func trigger_now(event_id: StringName) -> bool:
	if not _can_trigger.has(event_id) or not _can_trigger[event_id].call():
		return false
	_trigger[event_id].call()
	event_triggered.emit(event_id)
	return true


## Devolve os ids dos eventos que têm quem os trate.
func registered_events() -> Array[StringName]:
	return _can_trigger.keys()


## Zera os intervalos e as contagens do sorteio para a noite que começa.
func reset_night() -> void:
	_scheduler.reset_night()


## Diz se o evento tem quem o trate e se esse sistema aceita dispará-lo agora.
func _is_eligible(definition: EventDefinition) -> bool:
	if not _can_trigger.has(definition.id):
		return false
	return _can_trigger[definition.id].call()
