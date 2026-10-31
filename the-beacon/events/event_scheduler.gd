class_name EventScheduler
extends RefCounted
## Sorteio dos eventos da noite (GDD 1.2.8): cada evento tenta disparar a cada intervalo,
## só dentro da janela de horário, até o limite por noite e se estiver elegível.

var _definitions: Array[EventDefinition] = []
var _timers: Dictionary[StringName, float] = {}
var _counts: Dictionary[StringName, int] = {}


func add(definition: EventDefinition) -> void:
	_definitions.append(definition)
	_timers[definition.id] = 0.0
	_counts[definition.id] = 0


## Avança os intervalos e devolve os eventos sorteados neste passo.
## `is_eligible` recebe a definição e diz se o evento pode acontecer agora.
func update(
	delta: float,
	clock_hour: float,
	chance_multiplier: float,
	rng: RandomNumberGenerator,
	is_eligible: Callable
) -> Array[EventDefinition]:
	var fired: Array[EventDefinition] = []
	for definition: EventDefinition in _definitions:
		_timers[definition.id] += delta
		if _timers[definition.id] < definition.check_interval_seconds:
			continue
		_timers[definition.id] -= definition.check_interval_seconds
		if not _can_roll(definition, clock_hour) or not is_eligible.call(definition):
			continue
		if rng.randf() < definition.chance_per_check * chance_multiplier:
			_counts[definition.id] += 1
			fired.append(definition)
	return fired


func count_tonight(event_id: StringName) -> int:
	return _counts.get(event_id, 0)


func reset_night() -> void:
	for event_id: StringName in _timers:
		_timers[event_id] = 0.0
		_counts[event_id] = 0


func to_dict() -> Dictionary:
	var timers: Dictionary = {}
	var counts: Dictionary = {}
	for event_id: StringName in _timers:
		timers[String(event_id)] = _timers[event_id]
		counts[String(event_id)] = _counts[event_id]
	return {"timers": timers, "counts": counts}


func from_dict(data: Dictionary) -> void:
	var timers: Dictionary = data.get("timers", {})
	var counts: Dictionary = data.get("counts", {})
	for event_id: StringName in _timers:
		_timers[event_id] = float(timers.get(String(event_id), 0.0))
		_counts[event_id] = int(counts.get(String(event_id), 0))


func _can_roll(definition: EventDefinition, clock_hour: float) -> bool:
	if definition.max_per_night > 0 and _counts[definition.id] >= definition.max_per_night:
		return false
	return NightClock.is_hour_in_window(
		clock_hour, definition.window_start_hour, definition.window_end_hour
	)
