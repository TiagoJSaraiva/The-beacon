extends GdUnitTestSuite


func test_drain_reduces_until_empty() -> void:
	var battery := FlashlightBattery.new(10.0)
	assert_bool(battery.drain(4.0)).is_true()
	assert_float(battery.ratio()).is_equal_approx(0.6, 0.0001)
	assert_bool(battery.drain(10.0)).is_false()
	assert_bool(battery.is_empty()).is_true()
	assert_float(battery.remaining_seconds).is_equal_approx(0.0, 0.0001)


func test_save_round_trip_keeps_remaining() -> void:
	var battery := FlashlightBattery.new(10.0)
	battery.drain(3.5)
	var restored := FlashlightBattery.new(10.0)
	restored.from_dict(battery.to_dict())
	assert_float(restored.remaining_seconds).is_equal_approx(6.5, 0.0001)


func test_from_dict_clamps_to_capacity() -> void:
	var battery := FlashlightBattery.new(10.0)
	battery.from_dict({"remaining_seconds": 99.0})
	assert_float(battery.remaining_seconds).is_equal_approx(10.0, 0.0001)
