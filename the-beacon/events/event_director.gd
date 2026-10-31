class_name EventDirector
extends Node
## Roda o sorteio dos eventos enquanto a noite corre. Cada sistema registra os eventos
## que trata (decisão 0008); evento sem registro nunca dispara.

signal event_triggered(event_id: StringName)

@export var night: NightDirector

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _difficulty: DifficultyConfig
var _scheduler: EventScheduler = EventScheduler.new()
var _can_trigger: Dictionary[StringName, Callable] = {}
var _trigger: Dictionary[StringName, Callable] = {}


func _ready() -> void:
	rng.randomize()
	if night == null:
		push_warning("EventDirector sem night atribuído")
		set_process(false)


func _process(delta: float) -> void:
	if _difficulty == null or not night.is_running:
		return
	var multiplier: float = _difficulty.chance_multiplier_for_night(night.current_night)
	var fired: Array[EventDefinition] = _scheduler.update(
		delta, night.clock.clock_hour(), multiplier, rng, _is_eligible
	)
	for definition: EventDefinition in fired:
		_trigger[definition.id].call()
		event_triggered.emit(definition.id)


func configure(difficulty: DifficultyConfig) -> void:
	_difficulty = difficulty
	_scheduler = EventScheduler.new()
	for definition: EventDefinition in difficulty.events:
		_scheduler.add(definition)


## Registra quem trata o evento: `can_trigger() -> bool` e `trigger() -> void`.
func register(event_id: StringName, can_trigger: Callable, trigger: Callable) -> void:
	_can_trigger[event_id] = can_trigger
	_trigger[event_id] = trigger


func reset_night() -> void:
	_scheduler.reset_night()


func to_dict() -> Dictionary:
	return _scheduler.to_dict()


func from_dict(data: Dictionary) -> void:
	_scheduler.from_dict(data)


func _is_eligible(definition: EventDefinition) -> bool:
	if not _can_trigger.has(definition.id):
		return false
	return _can_trigger[definition.id].call()
