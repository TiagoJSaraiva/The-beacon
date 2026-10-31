extends GdUnitTestSuite


func test_completes_after_duration() -> void:
	var progress := HoldProgress.new(2.0)
	assert_bool(progress.advance(1.0)).is_false()
	assert_float(progress.ratio()).is_equal_approx(0.5, 0.0001)
	assert_bool(progress.advance(1.5)).is_true()
	assert_float(progress.ratio()).is_equal_approx(1.0, 0.0001)


func test_reset_returns_to_zero() -> void:
	var progress := HoldProgress.new(2.0)
	progress.advance(1.5)
	progress.reset()
	assert_float(progress.ratio()).is_equal_approx(0.0, 0.0001)
	assert_bool(progress.is_complete()).is_false()


func test_zero_duration_is_instant() -> void:
	var progress := HoldProgress.new(0.0)
	assert_bool(progress.advance(0.0)).is_true()
	assert_float(progress.ratio()).is_equal_approx(1.0, 0.0001)
