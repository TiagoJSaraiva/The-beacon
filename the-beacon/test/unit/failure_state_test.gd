extends GdUnitTestSuite


func test_starts_intact_and_can_break() -> void:
	var failure := FailureState.new(30.0)
	assert_bool(failure.is_broken).is_false()
	assert_bool(failure.can_break()).is_true()


func test_broken_cannot_break_again() -> void:
	var failure := FailureState.new(30.0)
	failure.break_down()
	assert_bool(failure.is_broken).is_true()
	assert_bool(failure.can_break()).is_false()


func test_repair_starts_cooldown_before_next_break() -> void:
	var failure := FailureState.new(30.0)
	failure.break_down()
	failure.repair()
	assert_bool(failure.is_broken).is_false()
	failure.tick(29.0)
	assert_bool(failure.can_break()).is_false()
	failure.tick(1.0)
	assert_bool(failure.can_break()).is_true()


func test_cooldown_does_not_run_while_broken() -> void:
	var failure := FailureState.new(30.0)
	failure.break_down()
	failure.repair()
	failure.break_down()
	failure.tick(100.0)
	failure.repair()
	assert_bool(failure.can_break()).is_false()
