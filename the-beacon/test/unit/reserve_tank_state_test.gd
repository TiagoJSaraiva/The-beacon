extends GdUnitTestSuite


func _config() -> PowerConfig:
	var config := PowerConfig.new()
	config.reserve_capacity = 100.0
	config.reserve_start_fuel = 100.0
	config.reserve_leak_per_second = 2.0
	return config


func test_draw_takes_requested_amount() -> void:
	var tank := ReserveTankState.new(_config())
	assert_float(tank.draw(25.0)).is_equal_approx(25.0, 0.0001)
	assert_float(tank.fuel).is_equal_approx(75.0, 0.0001)


func test_draw_is_limited_by_what_is_left() -> void:
	var tank := ReserveTankState.new(_config())
	tank.fuel = 10.0
	assert_float(tank.draw(25.0)).is_equal_approx(10.0, 0.0001)
	assert_bool(tank.can_fill()).is_false()


func test_broken_hose_leaks_and_blocks_filling() -> void:
	var tank := ReserveTankState.new(_config())
	tank.hose_broken = true
	tank.tick(10.0)
	assert_float(tank.fuel).is_equal_approx(80.0, 0.0001)
	assert_float(tank.draw(25.0)).is_equal_approx(0.0, 0.0001)


func test_intact_hose_does_not_leak() -> void:
	var tank := ReserveTankState.new(_config())
	tank.tick(10.0)
	assert_float(tank.fuel).is_equal_approx(100.0, 0.0001)


func test_save_round_trip() -> void:
	var tank := ReserveTankState.new(_config())
	tank.draw(30.0)
	tank.hose_broken = true
	var restored := ReserveTankState.new(_config())
	restored.from_dict(tank.to_dict())
	assert_float(restored.fuel).is_equal_approx(70.0, 0.0001)
	assert_bool(restored.hose_broken).is_true()
