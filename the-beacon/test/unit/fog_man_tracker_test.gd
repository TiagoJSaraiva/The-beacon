extends GdUnitTestSuite


func _config() -> FogManConfig:
	var config := FogManConfig.new()
	config.dissipate_seconds = 1.5
	config.spawn_cooldown_seconds = 60.0
	return config


func test_spawns_only_with_dense_fog_and_none_active() -> void:
	var tracker := FogManTracker.new(_config())
	assert_bool(tracker.can_spawn(false, false)).is_false()
	assert_bool(tracker.can_spawn(true, true)).is_false()
	assert_bool(tracker.can_spawn(true, false)).is_true()


func test_cooldown_after_vanishing() -> void:
	var tracker := FogManTracker.new(_config())
	tracker.on_vanished()
	assert_bool(tracker.can_spawn(true, false)).is_false()
	tracker.tick_cooldown(60.0)
	assert_bool(tracker.can_spawn(true, false)).is_true()


func test_dissipates_after_continuous_light() -> void:
	var tracker := FogManTracker.new(_config())
	assert_bool(tracker.update_light(1.0, true)).is_false()
	assert_bool(tracker.update_light(0.6, true)).is_true()


func test_light_must_be_continuous() -> void:
	var tracker := FogManTracker.new(_config())
	tracker.update_light(1.0, true)
	tracker.update_light(0.1, false)
	assert_bool(tracker.update_light(1.0, true)).is_false()


func test_save_round_trip() -> void:
	var tracker := FogManTracker.new(_config())
	tracker.on_vanished()
	tracker.tick_cooldown(10.0)
	var restored := FogManTracker.new(_config())
	restored.from_dict(tracker.to_dict())
	assert_float(restored.cooldown_remaining).is_equal_approx(50.0, 0.0001)
