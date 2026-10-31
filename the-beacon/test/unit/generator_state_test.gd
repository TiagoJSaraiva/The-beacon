extends GdUnitTestSuite


func _config() -> PowerConfig:
	var config := PowerConfig.new()
	config.generator_capacity = 100.0
	config.generator_start_fuel = 50.0
	config.generator_consumption_per_second = 1.0
	config.beam_extra_consumption_per_second = 2.0
	return config


func test_consumes_base_rate_while_running() -> void:
	var state := GeneratorState.new(_config())
	state.tick(10.0)
	assert_float(state.fuel).is_equal_approx(40.0, 0.0001)


func test_beam_adds_extra_consumption() -> void:
	var state := GeneratorState.new(_config())
	state.beam_load = true
	state.tick(10.0)
	assert_float(state.fuel).is_equal_approx(20.0, 0.0001)


func test_stops_when_out_of_fuel() -> void:
	var state := GeneratorState.new(_config())
	state.tick(100.0)
	assert_float(state.fuel).is_equal_approx(0.0, 0.0001)
	assert_bool(state.is_running()).is_false()


func test_broken_generator_neither_runs_nor_consumes() -> void:
	var state := GeneratorState.new(_config())
	state.is_broken = true
	state.tick(10.0)
	assert_bool(state.is_running()).is_false()
	assert_float(state.fuel).is_equal_approx(50.0, 0.0001)


func test_add_fuel_caps_at_capacity() -> void:
	var state := GeneratorState.new(_config())
	assert_float(state.add_fuel(30.0)).is_equal_approx(30.0, 0.0001)
	assert_float(state.add_fuel(30.0)).is_equal_approx(20.0, 0.0001)
	assert_float(state.fuel).is_equal_approx(100.0, 0.0001)


func test_save_round_trip() -> void:
	var state := GeneratorState.new(_config())
	state.tick(5.0)
	state.is_broken = true
	var restored := GeneratorState.new(_config())
	restored.from_dict(state.to_dict())
	assert_float(restored.fuel).is_equal_approx(45.0, 0.0001)
	assert_bool(restored.is_broken).is_true()
