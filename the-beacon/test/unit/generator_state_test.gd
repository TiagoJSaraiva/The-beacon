extends GdUnitTestSuite


func _config() -> PowerConfig:
	var config := PowerConfig.new()
	config.generator_capacity = 100.0
	config.generator_start_fuel = 50.0
	config.generator_consumption_per_second = 1.0
	return config


func test_hose_generator_runs_while_hose_is_intact_without_fuel() -> void:
	var state := GeneratorState.new(_config(), GeneratorState.Feed.HOSE)
	state.in_use = true
	state.tick(100.0)
	assert_bool(state.is_running()).is_true()
	assert_float(state.fuel).is_equal_approx(0.0, 0.0001)
	state.hose_intact = false
	assert_bool(state.is_running()).is_false()


func test_hose_generator_accepts_no_fuel() -> void:
	var state := GeneratorState.new(_config(), GeneratorState.Feed.HOSE)
	assert_float(state.add_fuel(30.0)).is_equal_approx(0.0, 0.0001)


func test_fuel_generator_consumes_only_in_use() -> void:
	var state := GeneratorState.new(_config(), GeneratorState.Feed.FUEL)
	state.tick(10.0)
	assert_float(state.fuel).is_equal_approx(50.0, 0.0001)
	state.in_use = true
	state.tick(10.0)
	assert_float(state.fuel).is_equal_approx(40.0, 0.0001)


func test_fuel_generator_stops_when_out_of_fuel() -> void:
	var state := GeneratorState.new(_config(), GeneratorState.Feed.FUEL)
	state.in_use = true
	state.tick(100.0)
	assert_float(state.fuel).is_equal_approx(0.0, 0.0001)
	assert_bool(state.is_running()).is_false()


func test_add_fuel_caps_at_capacity() -> void:
	var state := GeneratorState.new(_config(), GeneratorState.Feed.FUEL)
	assert_float(state.add_fuel(30.0)).is_equal_approx(30.0, 0.0001)
	assert_float(state.add_fuel(30.0)).is_equal_approx(20.0, 0.0001)
	assert_float(state.fuel).is_equal_approx(100.0, 0.0001)


func test_set_fuel_ratio_clamps_and_ignores_hose() -> void:
	var generator := GeneratorState.new(_config(), GeneratorState.Feed.FUEL)
	generator.set_fuel_ratio(0.25)
	assert_float(generator.fuel).is_equal_approx(25.0, 0.0001)
	generator.set_fuel_ratio(2.0)
	assert_float(generator.fuel_ratio()).is_equal_approx(1.0, 0.0001)
	generator.set_fuel_ratio(0.0)
	assert_bool(generator.is_running()).is_false()

	var hose := GeneratorState.new(_config(), GeneratorState.Feed.HOSE)
	hose.set_fuel_ratio(1.0)
	assert_float(hose.fuel).is_equal(0.0)
