extends GdUnitTestSuite


func test_starts_on_first_night() -> void:
	var run := RunState.new(&"easy", 3, 100.0)
	assert_int(run.current_night).is_equal(1)
	assert_bool(run.is_last_night()).is_false()


func test_advances_until_last_night() -> void:
	var run := RunState.new(&"easy", 3, 100.0)
	run.advance_night()
	run.advance_night()
	assert_bool(run.is_last_night()).is_true()
	run.advance_night()
	assert_int(run.current_night).is_equal(3)


func test_new_run_starts_clean_with_full_battery() -> void:
	var difficulty := DifficultyConfig.new()
	difficulty.id = &"medium"
	difficulty.nights = 5
	difficulty.flashlight = FlashlightConfig.new()
	difficulty.flashlight.battery_seconds = 240.0
	var run := RunState.new_run(difficulty)
	assert_str(String(run.difficulty_id)).is_equal("medium")
	assert_int(run.total_nights).is_equal(5)
	assert_int(run.current_night).is_equal(1)
	assert_int(run.drowned_points).is_equal(0)
	assert_bool(run.hose_broken).is_false()
	assert_float(run.flashlight_battery_seconds).is_equal(240.0)
	assert_array(run.tutorial_shown_ids).is_empty()


func test_save_round_trip_through_json() -> void:
	var run := RunState.new(&"medium", 5, 300.0)
	run.advance_night()
	run.drowned_points = 3
	run.hose_broken = true
	run.flashlight_battery_seconds = 42.5
	run.tutorial_shown_ids = [&"start", &"fog"]
	var restored := RunState.new()
	restored.from_dict(JSON.parse_string(JSON.stringify(run.to_dict())))
	assert_str(String(restored.difficulty_id)).is_equal("medium")
	assert_int(restored.total_nights).is_equal(5)
	assert_int(restored.current_night).is_equal(2)
	assert_int(restored.drowned_points).is_equal(3)
	assert_bool(restored.hose_broken).is_true()
	assert_float(restored.flashlight_battery_seconds).is_equal(42.5)
	assert_array(restored.tutorial_shown_ids).contains_exactly([&"start", &"fog"])


func test_from_dict_clamps_invalid_values() -> void:
	var invalid: Dictionary = {
		"total_nights": 3,
		"current_night": 9,
		"drowned_points": -2,
		"flashlight_battery_seconds": -5.0,
	}
	var run := RunState.new()
	run.from_dict(invalid)
	assert_int(run.current_night).is_equal(3)
	assert_int(run.drowned_points).is_equal(0)
	assert_float(run.flashlight_battery_seconds).is_equal(0.0)
