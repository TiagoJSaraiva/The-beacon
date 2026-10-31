extends GdUnitTestSuite


func _clock() -> NightClock:
	var config := TimeConfig.new()
	config.night_start_hour = 20
	config.night_end_hour = 6
	config.real_seconds_per_game_hour = 90.0
	return NightClock.new(config)


func test_night_lasts_fifteen_minutes() -> void:
	var clock := _clock()
	assert_float(clock.night_length_hours()).is_equal_approx(10.0, 0.0001)
	assert_float(clock.duration_seconds()).is_equal_approx(900.0, 0.0001)


func test_display_follows_game_time() -> void:
	var clock := _clock()
	assert_str(clock.display_text()).is_equal("20:00")
	clock.advance(45.0)
	assert_str(clock.display_text()).is_equal("20:30")
	clock.advance(315.0)
	assert_str(clock.display_text()).is_equal("00:00")


func test_night_ends_at_six_and_clamps() -> void:
	var clock := _clock()
	assert_bool(clock.advance(899.0)).is_false()
	assert_bool(clock.advance(5.0)).is_true()
	assert_str(clock.display_text()).is_equal("06:00")
	assert_float(clock.elapsed_seconds).is_equal_approx(900.0, 0.0001)


func test_reset_returns_to_start() -> void:
	var clock := _clock()
	clock.advance(300.0)
	clock.reset()
	assert_str(clock.display_text()).is_equal("20:00")


func test_window_crossing_midnight() -> void:
	assert_bool(NightClock.is_hour_in_window(23.0, 22.0, 4.0)).is_true()
	assert_bool(NightClock.is_hour_in_window(2.0, 22.0, 4.0)).is_true()
	assert_bool(NightClock.is_hour_in_window(4.0, 22.0, 4.0)).is_false()
	assert_bool(NightClock.is_hour_in_window(21.0, 22.0, 4.0)).is_false()


func test_window_within_same_day() -> void:
	assert_bool(NightClock.is_hour_in_window(1.0, 0.5, 3.0)).is_true()
	assert_bool(NightClock.is_hour_in_window(23.0, 0.5, 3.0)).is_false()


func test_save_round_trip() -> void:
	var clock := _clock()
	clock.advance(123.0)
	var restored := _clock()
	restored.from_dict(clock.to_dict())
	assert_float(restored.elapsed_seconds).is_equal_approx(123.0, 0.0001)
