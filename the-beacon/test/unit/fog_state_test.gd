extends GdUnitTestSuite


func _config() -> FogConfig:
	var config := FogConfig.new()
	config.min_duration_seconds = 100.0
	config.max_duration_seconds = 100.0
	config.min_intensity = 0.5
	config.max_intensity = 0.5
	config.intensity_change_per_second = 0.1
	config.retarget_interval_seconds = 1000.0
	config.fog_man_threshold = 0.8
	return config


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return rng


func test_starts_without_fog() -> void:
	var fog := FogState.new(_config())
	assert_bool(fog.is_present()).is_false()


func test_intensity_ramps_toward_target() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	fog.tick(2.0, rng)
	assert_float(fog.intensity).is_equal_approx(0.2, 0.0001)
	fog.tick(10.0, rng)
	assert_float(fog.intensity).is_equal_approx(0.5, 0.0001)
	assert_bool(fog.is_present()).is_true()


func test_fades_out_after_duration() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	fog.tick(10.0, rng)
	fog.tick(95.0, rng)
	assert_bool(fog.is_active).is_false()
	fog.tick(10.0, rng)
	assert_float(fog.intensity).is_equal_approx(0.0, 0.0001)
	assert_bool(fog.is_present()).is_false()


func test_strong_fog_covers_lighthouse_camera() -> void:
	var config := _config()
	config.min_intensity = 0.9
	config.max_intensity = 0.9
	var fog := FogState.new(config)
	var rng := _rng()
	fog.start(rng)
	fog.tick(5.0, rng)
	assert_bool(fog.covers_lighthouse_camera()).is_false()
	fog.tick(5.0, rng)
	assert_bool(fog.covers_lighthouse_camera()).is_true()


func test_clear_removes_fog_immediately() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	fog.tick(10.0, rng)
	fog.clear()
	assert_bool(fog.is_present()).is_false()
	assert_bool(fog.is_active).is_false()


func test_save_round_trip() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	fog.tick(3.0, rng)
	var restored := FogState.new(_config())
	restored.from_dict(fog.to_dict())
	assert_float(restored.intensity).is_equal_approx(fog.intensity, 0.0001)
	assert_bool(restored.is_active).is_true()
	assert_float(restored.remaining_seconds).is_equal_approx(fog.remaining_seconds, 0.0001)
