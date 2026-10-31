extends GdUnitTestSuite


func _event(chance: float, max_per_night: int = 0) -> EventDefinition:
	var event := EventDefinition.new()
	event.id = &"test_event"
	event.window_start_hour = 22.0
	event.window_end_hour = 4.0
	event.check_interval_seconds = 10.0
	event.chance_per_check = chance
	event.max_per_night = max_per_night
	return event


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	return rng


func _always(_definition: EventDefinition) -> bool:
	return true


func _never(_definition: EventDefinition) -> bool:
	return false


func test_rolls_only_after_interval() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0))
	assert_array(scheduler.update(9.0, 23.0, 1.0, _rng(), _always)).is_empty()
	assert_array(scheduler.update(1.0, 23.0, 1.0, _rng(), _always)).has_size(1)


func test_outside_window_never_fires() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0))
	assert_array(scheduler.update(10.0, 21.0, 1.0, _rng(), _always)).is_empty()
	assert_array(scheduler.update(10.0, 4.5, 1.0, _rng(), _always)).is_empty()


func test_window_crosses_midnight() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0))
	assert_array(scheduler.update(10.0, 2.0, 1.0, _rng(), _always)).has_size(1)


func test_zero_chance_never_fires() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(0.0))
	for i in 50:
		assert_array(scheduler.update(10.0, 23.0, 1.0, _rng(), _always)).is_empty()


func test_multiplier_scales_chance() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(0.5))
	var rng := _rng()
	var fired: int = 0
	for i in 200:
		fired += scheduler.update(10.0, 23.0, 2.0, rng, _always).size()
	assert_int(fired).is_equal(200)


func test_respects_max_per_night_and_reset() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0, 2))
	var rng := _rng()
	var fired: int = 0
	for i in 10:
		fired += scheduler.update(10.0, 23.0, 1.0, rng, _always).size()
	assert_int(fired).is_equal(2)
	scheduler.reset_night()
	assert_int(scheduler.count_tonight(&"test_event")).is_equal(0)
	assert_array(scheduler.update(10.0, 23.0, 1.0, rng, _always)).has_size(1)


func test_ineligible_event_does_not_fire_or_count() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0, 1))
	assert_array(scheduler.update(10.0, 23.0, 1.0, _rng(), _never)).is_empty()
	assert_int(scheduler.count_tonight(&"test_event")).is_equal(0)


func test_save_round_trip() -> void:
	var scheduler := EventScheduler.new()
	scheduler.add(_event(1.0))
	scheduler.update(10.0, 23.0, 1.0, _rng(), _always)
	scheduler.update(4.0, 23.0, 1.0, _rng(), _always)
	var restored := EventScheduler.new()
	restored.add(_event(1.0))
	restored.from_dict(scheduler.to_dict())
	assert_int(restored.count_tonight(&"test_event")).is_equal(1)
	assert_array(restored.update(6.0, 23.0, 1.0, _rng(), _always)).has_size(1)
