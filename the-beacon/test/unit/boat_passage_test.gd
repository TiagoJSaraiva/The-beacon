extends GdUnitTestSuite


func _config() -> BoatConfig:
	var config := BoatConfig.new()
	config.passage_seconds = 100.0
	config.sink_seconds_at_min_intensity = 60.0
	config.sink_seconds_at_max_intensity = 20.0
	return config


func test_passes_safely_without_fog() -> void:
	var passage := BoatPassage.new(_config(), false)
	passage.tick(100.0, 0.0, false)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.PASSED)


func test_sinks_in_fog_with_beam_off() -> void:
	var passage := BoatPassage.new(_config(), false)
	for i in 21:
		passage.tick(1.0, 1.0, false)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.SANK)


func test_beam_pauses_countdown() -> void:
	var passage := BoatPassage.new(_config(), false)
	passage.tick(10.0, 1.0, false)
	passage.tick(50.0, 1.0, true)
	assert_float(passage.sink_progress).is_equal_approx(0.5, 0.0001)
	passage.tick(40.0, 1.0, true)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.PASSED)


func test_countdown_resumes_when_beam_turns_off() -> void:
	var passage := BoatPassage.new(_config(), false)
	passage.tick(10.0, 1.0, false)
	passage.tick(10.0, 1.0, true)
	passage.tick(10.0, 1.0, false)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.SANK)


func test_stronger_fog_sinks_faster() -> void:
	var weak: float = BoatPassage.sink_seconds(0.0, _config())
	var strong: float = BoatPassage.sink_seconds(1.0, _config())
	assert_float(weak).is_equal_approx(60.0, 0.0001)
	assert_float(strong).is_equal_approx(20.0, 0.0001)
	assert_float(BoatPassage.sink_seconds(0.5, _config())).is_between(strong, weak)


func test_pirate_never_sinks_and_is_guided_by_beam() -> void:
	var passage := BoatPassage.new(_config(), true)
	passage.tick(50.0, 1.0, false)
	assert_bool(passage.pirate_guided).is_false()
	passage.tick(1.0, 1.0, true)
	assert_bool(passage.pirate_guided).is_true()
	passage.tick(60.0, 1.0, false)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.PASSED)


func test_save_round_trip() -> void:
	var passage := BoatPassage.new(_config(), false)
	passage.tick(10.0, 0.5, false)
	passage.was_answered = true
	var restored := BoatPassage.new(_config(), true)
	restored.from_dict(passage.to_dict())
	assert_bool(restored.is_pirate).is_false()
	assert_bool(restored.was_answered).is_true()
	assert_float(restored.sink_progress).is_equal_approx(passage.sink_progress, 0.0001)
	assert_float(restored.elapsed_seconds).is_equal_approx(10.0, 0.0001)
