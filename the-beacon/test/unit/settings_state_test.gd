extends GdUnitTestSuite


func test_defaults_are_full_volume_and_normal_sensitivity() -> void:
	var settings := SettingsState.new()
	assert_float(settings.master_volume).is_equal(1.0)
	assert_float(settings.sfx_volume).is_equal(1.0)
	assert_float(settings.sensitivity_scale).is_equal(1.0)


func test_out_of_range_values_are_clamped() -> void:
	var settings := SettingsState.new()
	var saved: Dictionary = {
		"master_volume": 3.0,
		"music_volume": -1.0,
		"sfx_volume": 0.5,
		"sensitivity_scale": 99.0,
	}
	settings.from_dict(saved)
	assert_float(settings.master_volume).is_equal(SettingsState.MAX_VOLUME)
	assert_float(settings.music_volume).is_equal(SettingsState.MIN_VOLUME)
	assert_float(settings.sfx_volume).is_equal(0.5)
	assert_float(settings.sensitivity_scale).is_equal(SettingsState.MAX_SENSITIVITY_SCALE)


func test_missing_keys_keep_current_values() -> void:
	var settings := SettingsState.new()
	settings.music_volume = 0.3
	settings.from_dict({"sfx_volume": 0.2})
	assert_float(settings.music_volume).is_equal_approx(0.3, 0.0001)
	assert_float(settings.sfx_volume).is_equal_approx(0.2, 0.0001)


func test_save_round_trip() -> void:
	var settings := SettingsState.new()
	settings.master_volume = 0.4
	settings.sensitivity_scale = 1.5
	var restored := SettingsState.new()
	restored.from_dict(settings.to_dict())
	assert_float(restored.master_volume).is_equal_approx(0.4, 0.0001)
	assert_float(restored.sensitivity_scale).is_equal_approx(1.5, 0.0001)
