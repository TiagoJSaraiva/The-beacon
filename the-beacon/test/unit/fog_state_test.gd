extends GdUnitTestSuite

const STEP := 0.1


func _config() -> FogConfig:
	var config := FogConfig.new()
	config.start_advance = 0.05
	config.near_advance = 0.3
	config.ground_floor_advance = 0.45
	config.stairs_advance = 0.6
	config.trapdoor_advance = 0.75
	config.cabin_advance = 0.9
	config.beam_cover_advance = 1.0
	config.route_center = 0.5
	config.max_route_coverage = 0.5
	config.idle_grace_seconds = 10.0
	config.advance_per_second = 0.1
	config.recoil_ratio = 0.5
	config.unblock_seconds = 5.0
	config.recede_per_second = 0.01
	return config


## Avança `seconds` em passos pequenos, como os frames do jogo.
func _run(fog: FogState, seconds: float, operational: bool) -> void:
	for _step: int in roundi(seconds / STEP):
		fog.tick(STEP, operational)


func test_event_starts_fog_at_sea() -> void:
	var fog := FogState.new(_config())
	assert_int(fog.stage()).is_equal(FogStage.Stage.NONE)
	fog.start()
	assert_int(fog.phase).is_equal(FogState.Phase.PRESENT)
	assert_float(fog.advance).is_equal_approx(0.05, 0.0001)
	assert_int(fog.stage()).is_equal(FogStage.Stage.SEA)
	assert_bool(fog.can_start()).is_false()


func test_stopped_lighthouse_brings_fog_after_grace() -> void:
	var fog := FogState.new(_config())
	_run(fog, 9.0, false)
	assert_int(fog.phase).is_equal(FogState.Phase.CLEAR)
	_run(fog, 2.0, false)
	assert_int(fog.phase).is_equal(FogState.Phase.PRESENT)
	assert_float(fog.advance).is_greater(0.05)


func test_fog_never_goes_away_while_the_lighthouse_operates() -> void:
	var fog := FogState.new(_config())
	fog.start()
	_run(fog, 600.0, true)
	assert_int(fog.phase).is_equal(FogState.Phase.PRESENT)
	assert_float(fog.advance).is_equal_approx(0.05, 0.0001)
	assert_bool(fog.can_start()).is_false()


func test_stopped_lighthouse_lets_fog_advance_through_every_stage() -> void:
	var fog := FogState.new(_config())
	fog.start()
	_run(fog, 3.0, false)
	assert_int(fog.stage()).is_equal(FogStage.Stage.NEAR)
	assert_bool(fog.blocks_beam()).is_false()
	_run(fog, 2.0, false)
	assert_int(fog.stage()).is_equal(FogStage.Stage.GROUND_FLOOR)
	_run(fog, 4.0, false)
	assert_int(fog.stage()).is_equal(FogStage.Stage.CABIN)
	assert_bool(fog.blocks_beam()).is_false()
	_run(fog, 1.0, false)
	assert_float(fog.advance).is_equal_approx(1.0, 0.0001)
	assert_int(fog.stage()).is_equal(FogStage.Stage.BEAM)
	assert_bool(fog.blocks_beam()).is_true()


func test_resuming_recoils_half_of_the_last_expansion_at_once() -> void:
	var fog := FogState.new(_config())
	fog.start()
	_run(fog, 2.0, true)
	fog.tick(4.0, false)
	assert_float(fog.advance).is_equal_approx(0.45, 0.0001)
	fog.tick(STEP, true)
	assert_float(fog.advance).is_equal_approx(0.25, 0.0001)


func test_only_the_latest_expansion_counts_for_the_recoil() -> void:
	var fog := FogState.new(_config())
	fog.start()
	fog.tick(4.0, false)
	fog.tick(STEP, true)
	var after_first: float = fog.advance
	fog.tick(2.0, false)
	fog.tick(STEP, true)
	assert_float(fog.advance).is_equal_approx(after_first + 0.1, 0.0001)


func test_operating_lighthouse_recedes_slowly_down_to_the_start_level() -> void:
	var fog := FogState.new(_config())
	fog.start()
	fog.tick(4.0, false)
	fog.tick(STEP, true)
	var after_recoil: float = fog.advance
	_run(fog, 5.0, true)
	assert_float(fog.advance).is_equal_approx(after_recoil - 0.05, 0.001)
	_run(fog, 60.0, true)
	assert_float(fog.advance).is_equal_approx(0.05, 0.0001)


func test_covered_beam_waits_before_the_recoil() -> void:
	var fog := FogState.new(_config())
	fog.start()
	_run(fog, 12.0, false)
	assert_bool(fog.blocks_beam()).is_true()
	_run(fog, 4.5, true)
	assert_float(fog.advance).is_equal_approx(1.0, 0.0001)
	assert_bool(fog.blocks_beam()).is_true()
	_run(fog, 1.0, true)
	assert_bool(fog.blocks_beam()).is_false()
	assert_float(fog.advance).is_between(0.5, 0.55)


func test_stopping_again_restarts_the_covered_beam_wait() -> void:
	var fog := FogState.new(_config())
	fog.start()
	_run(fog, 12.0, false)
	_run(fog, 4.0, true)
	_run(fog, 1.0, false)
	_run(fog, 4.0, true)
	assert_bool(fog.blocks_beam()).is_true()


func test_stage_thresholds() -> void:
	var config := _config()
	assert_int(FogStage.for_advance(0.0, config)).is_equal(FogStage.Stage.NONE)
	assert_int(FogStage.for_advance(0.29, config)).is_equal(FogStage.Stage.SEA)
	assert_int(FogStage.for_advance(0.3, config)).is_equal(FogStage.Stage.NEAR)
	assert_int(FogStage.for_advance(0.6, config)).is_equal(FogStage.Stage.STAIRS)
	assert_int(FogStage.for_advance(0.75, config)).is_equal(FogStage.Stage.TRAPDOOR)
	assert_int(FogStage.for_advance(0.95, config)).is_equal(FogStage.Stage.CABIN)
	assert_int(FogStage.for_advance(1.0, config)).is_equal(FogStage.Stage.BEAM)


func test_route_coverage_grows_around_the_fixed_center_but_never_closes_the_route() -> void:
	var fog := FogState.new(_config())
	assert_that(fog.route_segment()).is_equal(Vector2.ZERO)
	fog.start()
	var small: Vector2 = fog.route_segment()
	_run(fog, 20.0, false)
	var full: Vector2 = fog.route_segment()
	assert_float(full.y - full.x).is_greater(small.y - small.x)
	assert_float(full.y - full.x).is_equal_approx(0.5, 0.0001)
	assert_float((full.x + full.y) * 0.5).is_equal_approx(0.5, 0.0001)
	assert_float((small.x + small.y) * 0.5).is_equal_approx(0.5, 0.0001)


func test_config_rejects_recede_as_fast_as_the_advance() -> void:
	var config := _config()
	assert_array(Array(config.validate())).is_empty()
	config.recede_per_second = config.advance_per_second
	assert_array(Array(config.validate())).contains(
		["fog: recuo contínuo precisa ser mais lento que o avanço"]
	)
