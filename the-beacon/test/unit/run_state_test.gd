extends GdUnitTestSuite


func test_starts_on_first_night() -> void:
	var run := RunState.new(&"easy", 3)
	assert_int(run.current_night).is_equal(1)
	assert_bool(run.is_last_night()).is_false()


func test_advances_until_last_night() -> void:
	var run := RunState.new(&"easy", 3)
	run.advance_night()
	run.advance_night()
	assert_bool(run.is_last_night()).is_true()
	run.advance_night()
	assert_int(run.current_night).is_equal(3)


func test_save_round_trip() -> void:
	var run := RunState.new(&"medium", 5)
	run.advance_night()
	var restored := RunState.new(&"easy", 3)
	restored.from_dict(run.to_dict())
	assert_str(String(restored.difficulty_id)).is_equal("medium")
	assert_int(restored.total_nights).is_equal(5)
	assert_int(restored.current_night).is_equal(2)
