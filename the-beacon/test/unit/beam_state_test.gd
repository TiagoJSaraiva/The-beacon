extends GdUnitTestSuite


func test_starts_off() -> void:
	assert_bool(BeamState.new().is_active()).is_false()


func test_active_with_switch_power_and_lamp() -> void:
	var beam := BeamState.new()
	beam.switch_on = true
	assert_bool(beam.is_active()).is_true()


func test_no_power_turns_beam_off() -> void:
	var beam := BeamState.new()
	beam.switch_on = true
	beam.powered = false
	assert_bool(beam.is_active()).is_false()


func test_burned_lamp_turns_beam_off() -> void:
	var beam := BeamState.new()
	beam.switch_on = true
	beam.lamp_burned = true
	assert_bool(beam.is_active()).is_false()


func test_save_round_trip() -> void:
	var beam := BeamState.new()
	beam.switch_on = true
	beam.lamp_burned = true
	var restored := BeamState.new()
	restored.from_dict(beam.to_dict())
	assert_bool(restored.switch_on).is_true()
	assert_bool(restored.lamp_burned).is_true()
