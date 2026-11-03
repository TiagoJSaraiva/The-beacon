extends GdUnitTestSuite


func test_runs_only_while_banging_without_latch() -> void:
	var resistance := TrapdoorResistance.new(10.0)
	resistance.tick(3.0, false, false)
	assert_float(resistance.remaining_seconds).is_equal_approx(10.0, 0.0001)
	resistance.tick(3.0, true, false)
	assert_float(resistance.remaining_seconds).is_equal_approx(7.0, 0.0001)


func test_latch_freezes_and_release_does_not_reset() -> void:
	var resistance := TrapdoorResistance.new(10.0)
	resistance.tick(4.0, true, false)
	resistance.tick(5.0, true, true)
	assert_float(resistance.remaining_seconds).is_equal_approx(6.0, 0.0001)
	resistance.tick(1.0, true, false)
	assert_float(resistance.remaining_seconds).is_equal_approx(5.0, 0.0001)


func test_breaks_when_time_runs_out() -> void:
	var resistance := TrapdoorResistance.new(10.0)
	assert_bool(resistance.tick(9.0, true, false)).is_false()
	assert_bool(resistance.tick(1.5, true, false)).is_true()


func test_reset_restores_full_resistance() -> void:
	var resistance := TrapdoorResistance.new(10.0)
	resistance.tick(6.0, true, false)
	resistance.reset()
	assert_float(resistance.remaining_seconds).is_equal_approx(10.0, 0.0001)
