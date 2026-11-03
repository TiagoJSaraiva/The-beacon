extends GdUnitTestSuite


func test_drain_reduces_until_empty() -> void:
	var battery := FlashlightBattery.new(10.0)
	assert_bool(battery.drain(4.0)).is_true()
	assert_float(battery.ratio()).is_equal_approx(0.6, 0.0001)
	assert_bool(battery.drain(10.0)).is_false()
	assert_bool(battery.is_empty()).is_true()
	assert_float(battery.remaining_seconds).is_equal_approx(0.0, 0.0001)
