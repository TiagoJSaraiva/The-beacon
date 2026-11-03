extends GdUnitTestSuite


func _switched_on() -> BeamState:
	var beam := BeamState.new()
	beam.switch_on = true
	return beam


func test_starts_off() -> void:
	var beam := BeamState.new()
	assert_bool(beam.is_operational()).is_false()
	assert_bool(beam.is_lit()).is_false()


func test_operational_and_lit_with_lever_power_lamp_and_machine() -> void:
	var beam := _switched_on()
	assert_bool(beam.is_operational()).is_true()
	assert_bool(beam.is_lit()).is_true()


func test_each_failure_stops_the_lighthouse() -> void:
	var no_power := _switched_on()
	no_power.powered = false
	var burned := _switched_on()
	burned.lamp_burned = true
	var broken := _switched_on()
	broken.machine_broken = true
	for beam: BeamState in [no_power, burned, broken]:
		assert_bool(beam.is_operational()).is_false()
		assert_bool(beam.is_lit()).is_false()


func test_fog_blocks_the_beam_but_not_the_operation() -> void:
	var beam := _switched_on()
	beam.fog_blocking = true
	assert_bool(beam.is_operational()).is_true()
	assert_bool(beam.is_lit()).is_false()
