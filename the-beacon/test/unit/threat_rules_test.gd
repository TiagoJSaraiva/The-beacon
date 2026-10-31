extends GdUnitTestSuite


func _config() -> ThreatConfig:
	var config := ThreatConfig.new()
	config.threat_per_drowned_point = 1.0
	config.threat_from_broken_door = 0.5
	config.spawn_chance_base = 0.2
	config.spawn_chance_per_threat = 0.1
	config.extra_drowned_chance_per_threat = 0.5
	config.severe_action_weight_per_threat = 1.0
	return config


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	return rng


func test_threat_grows_with_points_and_broken_door() -> void:
	assert_float(ThreatRules.threat_level(0, false, _config())).is_equal_approx(0.0, 0.0001)
	assert_float(ThreatRules.threat_level(2, false, _config())).is_equal_approx(2.0, 0.0001)
	assert_float(ThreatRules.threat_level(2, true, _config())).is_equal_approx(2.5, 0.0001)


func test_spawn_chance_grows_and_caps() -> void:
	assert_float(ThreatRules.spawn_chance(1.0, _config())).is_equal_approx(0.3, 0.0001)
	assert_float(ThreatRules.spawn_chance(50.0, _config())).is_equal_approx(1.0, 0.0001)


func test_spawn_count_respects_max() -> void:
	var rng := _rng()
	for i in 50:
		assert_int(ThreatRules.spawn_count(10.0, 3, _config(), rng)).is_between(1, 3)


func test_no_extra_drowned_without_threat() -> void:
	var rng := _rng()
	for i in 50:
		assert_int(ThreatRules.spawn_count(0.0, 3, _config(), rng)).is_equal(1)


func test_generator_sabotage_more_likely_with_threat() -> void:
	var rng := _rng()
	var low: int = 0
	var high: int = 0
	for i in 400:
		low += 1 if ThreatRules.prefers_generator(0.2, _config(), rng) else 0
		high += 1 if ThreatRules.prefers_generator(5.0, _config(), rng) else 0
	assert_int(high).is_greater(low)
