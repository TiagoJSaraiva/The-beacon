extends GdUnitTestSuite


func _config() -> FallConfig:
	var config := FallConfig.new()
	config.slow_height = 2.5
	config.fatal_height = 6.0
	return config


func test_short_fall_has_no_effect() -> void:
	assert_int(FallRules.evaluate(1.0, _config())).is_equal(FallRules.Outcome.NONE)


func test_medium_fall_slows() -> void:
	assert_int(FallRules.evaluate(2.5, _config())).is_equal(FallRules.Outcome.SLOW)
	assert_int(FallRules.evaluate(5.9, _config())).is_equal(FallRules.Outcome.SLOW)


func test_high_fall_is_fatal() -> void:
	assert_int(FallRules.evaluate(6.0, _config())).is_equal(FallRules.Outcome.FATAL)
	assert_int(FallRules.evaluate(20.0, _config())).is_equal(FallRules.Outcome.FATAL)
