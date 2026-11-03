extends GdUnitTestSuite


func _generator(start_fuel: float) -> GeneratorState:
	var config := PowerConfig.new()
	config.generator_capacity = 100.0
	config.generator_start_fuel = start_fuel
	return GeneratorState.new(config, GeneratorState.Feed.FUEL)


func test_starts_full() -> void:
	var jerrycan := JerrycanState.new(25.0)
	assert_float(jerrycan.amount).is_equal_approx(25.0, 0.0001)


func test_slot_fills_from_empty_to_full_in_fill_seconds() -> void:
	var jerrycan := JerrycanState.new(25.0)
	jerrycan.amount = 0.0
	jerrycan.refill(60.0, 120.0)
	assert_float(jerrycan.ratio()).is_equal_approx(0.5, 0.0001)
	jerrycan.refill(60.0, 120.0)
	assert_float(jerrycan.ratio()).is_equal_approx(1.0, 0.0001)
	jerrycan.refill(60.0, 120.0)
	assert_float(jerrycan.amount).is_equal_approx(25.0, 0.0001)


func test_pour_keeps_what_generator_cannot_take() -> void:
	var generator := _generator(90.0)
	var jerrycan := JerrycanState.new(25.0)
	assert_float(jerrycan.pour_into(generator)).is_equal_approx(10.0, 0.0001)
	assert_float(jerrycan.amount).is_equal_approx(15.0, 0.0001)
	assert_float(generator.fuel).is_equal_approx(100.0, 0.0001)


func test_pour_empties_into_a_low_generator() -> void:
	var generator := _generator(20.0)
	var jerrycan := JerrycanState.new(25.0)
	jerrycan.pour_into(generator)
	assert_float(jerrycan.amount).is_equal_approx(0.0, 0.0001)
	assert_float(generator.fuel).is_equal_approx(45.0, 0.0001)
