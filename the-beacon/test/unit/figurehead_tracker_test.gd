extends GdUnitTestSuite


func _config() -> FigureheadConfig:
	var config := FigureheadConfig.new()
	config.max_simultaneous = 3
	config.spawn_interval_seconds = 5.0
	config.blinds_before_knockdown = 2
	config.dissolve_seconds = 0.3
	config.respawn_after_destroyed_seconds = 30.0
	config.respawn_after_attack_seconds = 50.0
	return config


func test_at_most_max_simultaneous() -> void:
	var tracker := FigureheadTracker.new(_config())
	assert_bool(tracker.can_spawn(2)).is_true()
	assert_bool(tracker.can_spawn(3)).is_false()


func test_spawns_are_spaced_out() -> void:
	var tracker := FigureheadTracker.new(_config())
	tracker.on_spawned()
	assert_bool(tracker.can_spawn(1)).is_false()
	tracker.tick(5.0)
	assert_bool(tracker.can_spawn(1)).is_true()


func test_destroyed_and_attacking_ones_have_separate_respawn_times() -> void:
	var tracker := FigureheadTracker.new(_config())
	tracker.on_destroyed()
	tracker.on_attacked()
	# Uma em cena e duas esperando a volta: sem vaga.
	assert_bool(tracker.can_spawn(1)).is_false()
	tracker.tick(30.0)
	assert_bool(tracker.can_spawn(1)).is_true()
	assert_bool(tracker.can_spawn(2)).is_false()
	tracker.tick(20.0)
	assert_bool(tracker.can_spawn(2)).is_true()


func test_attack_after_enough_blinds_knocks_down_and_counting_restarts() -> void:
	var tracker := FigureheadTracker.new(_config())
	assert_int(tracker.on_attacked()).is_equal(FigureheadTracker.Attack.BLIND)
	assert_int(tracker.on_attacked()).is_equal(FigureheadTracker.Attack.BLIND)
	assert_int(tracker.on_attacked()).is_equal(FigureheadTracker.Attack.KNOCKDOWN)
	assert_int(tracker.on_attacked()).is_equal(FigureheadTracker.Attack.BLIND)


func test_dissolves_after_continuous_light() -> void:
	var tracker := FigureheadTracker.new(_config())
	assert_bool(tracker.is_dissolved(0.2)).is_false()
	assert_bool(tracker.is_dissolved(0.3)).is_true()
