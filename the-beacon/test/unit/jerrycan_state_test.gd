extends GdUnitTestSuite


func _power() -> PowerConfig:
	var config := PowerConfig.new()
	config.reserve_capacity = 100.0
	config.reserve_start_fuel = 100.0
	config.generator_capacity = 100.0
	config.generator_start_fuel = 90.0
	config.jerrycan_capacity = 25.0
	return config


func test_fill_tops_up_to_capacity() -> void:
	var reserve := ReserveTankState.new(_power())
	var jerrycan := JerrycanState.new(25.0)
	jerrycan.amount = 5.0
	assert_float(jerrycan.fill_from(reserve)).is_equal_approx(20.0, 0.0001)
	assert_float(jerrycan.amount).is_equal_approx(25.0, 0.0001)
	assert_float(reserve.fuel).is_equal_approx(80.0, 0.0001)


func test_pour_keeps_what_generator_cannot_take() -> void:
	var generator := GeneratorState.new(_power())
	var jerrycan := JerrycanState.new(25.0)
	jerrycan.amount = 25.0
	assert_float(jerrycan.pour_into(generator)).is_equal_approx(10.0, 0.0001)
	assert_float(jerrycan.amount).is_equal_approx(15.0, 0.0001)
	assert_float(generator.fuel).is_equal_approx(100.0, 0.0001)


func test_full_refuel_cycle_moves_fuel_from_reserve_to_generator() -> void:
	var power := _power()
	power.generator_start_fuel = 50.0
	var reserve := ReserveTankState.new(power)
	var generator := GeneratorState.new(power)
	var jerrycan := JerrycanState.new(power.jerrycan_capacity)
	jerrycan.fill_from(reserve)
	jerrycan.pour_into(generator)
	assert_float(reserve.fuel).is_equal_approx(75.0, 0.0001)
	assert_float(generator.fuel).is_equal_approx(75.0, 0.0001)
	assert_float(jerrycan.amount).is_equal_approx(0.0, 0.0001)


func test_save_round_trip() -> void:
	var jerrycan := JerrycanState.new(25.0)
	jerrycan.amount = 12.0
	jerrycan.is_carried = true
	var restored := JerrycanState.new(25.0)
	restored.from_dict(jerrycan.to_dict())
	assert_float(restored.amount).is_equal_approx(12.0, 0.0001)
	assert_bool(restored.is_carried).is_true()
