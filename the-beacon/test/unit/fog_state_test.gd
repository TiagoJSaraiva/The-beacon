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
	config.sea_max_advance = 0.25
	config.sea_densify_per_second = 0.01
	config.min_duration_seconds = 100.0
	config.max_duration_seconds = 100.0
	config.max_route_coverage = 0.5
	config.idle_grace_seconds = 10.0
	config.advance_per_second = 0.1
	config.unblock_seconds = 5.0
	config.recede_to_advance = 0.15
	config.recede_per_second = 0.1
	return config


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return rng


## Avança `seconds` em passos pequenos, como os frames do jogo.
func _run(fog: FogState, seconds: float, operational: bool, rng: RandomNumberGenerator) -> void:
	for _step: int in roundi(seconds / STEP):
		fog.tick(STEP, operational, rng)


func test_event_starts_fog_at_sea() -> void:
	var fog := FogState.new(_config())
	assert_int(fog.stage()).is_equal(FogStage.Stage.NONE)
	fog.start(_rng())
	assert_int(fog.phase).is_equal(FogState.Phase.SEA)
	assert_float(fog.advance).is_equal_approx(0.05, 0.0001)
	assert_int(fog.stage()).is_equal(FogStage.Stage.SEA)
	assert_bool(fog.can_start()).is_false()


func test_stopped_lighthouse_brings_fog_after_grace() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	_run(fog, 9.0, false, rng)
	assert_int(fog.phase).is_equal(FogState.Phase.CLEAR)
	_run(fog, 2.0, false, rng)
	assert_int(fog.phase).is_equal(FogState.Phase.ADVANCING)
	assert_float(fog.advance).is_greater(0.05)


func test_operating_lighthouse_keeps_fog_at_sea_up_to_its_cap() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	_run(fog, 60.0, true, rng)
	assert_float(fog.advance).is_equal_approx(0.25, 0.0001)
	assert_int(fog.stage()).is_equal(FogStage.Stage.SEA)
	assert_bool(fog.blocks_beam()).is_false()


func test_fog_at_sea_dissipates_after_its_duration() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	_run(fog, 101.0, true, rng)
	assert_int(fog.phase).is_equal(FogState.Phase.CLEAR)
	_run(fog, 5.0, true, rng)
	assert_int(fog.stage()).is_equal(FogStage.Stage.NONE)


func test_stopped_lighthouse_lets_fog_advance_through_every_stage() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	_run(fog, 3.0, false, rng)
	assert_int(fog.stage()).is_equal(FogStage.Stage.NEAR)
	assert_bool(fog.blocks_beam()).is_true()
	_run(fog, 2.0, false, rng)
	assert_int(fog.stage()).is_equal(FogStage.Stage.GROUND_FLOOR)
	_run(fog, 10.0, false, rng)
	assert_float(fog.advance).is_equal_approx(1.0, 0.0001)
	assert_int(fog.stage()).is_equal(FogStage.Stage.CABIN)


func test_resuming_near_keeps_blocking_then_recedes_to_sea() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	_run(fog, 5.0, false, rng)
	var reached: float = fog.advance
	_run(fog, 4.5, true, rng)
	assert_int(fog.phase).is_equal(FogState.Phase.HOLDING)
	assert_float(fog.advance).is_equal_approx(reached, 0.0001)
	assert_bool(fog.blocks_beam()).is_true()
	_run(fog, 10.0, true, rng)
	assert_bool(fog.blocks_beam()).is_false()
	assert_int(fog.phase).is_equal(FogState.Phase.SEA)
	assert_float(fog.advance).is_between(0.15, 0.25)


func test_resuming_below_near_stops_the_advance() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	fog.start(rng)
	fog.tick(2.2, false, rng)
	var reached: float = fog.advance
	assert_float(reached).is_between(0.25, 0.3)
	_run(fog, 20.0, true, rng)
	assert_int(fog.phase).is_equal(FogState.Phase.SEA)
	assert_float(fog.advance).is_equal_approx(reached, 0.0001)


func test_stage_thresholds() -> void:
	var config := _config()
	assert_int(FogStage.for_advance(0.0, config)).is_equal(FogStage.Stage.NONE)
	assert_int(FogStage.for_advance(0.29, config)).is_equal(FogStage.Stage.SEA)
	assert_int(FogStage.for_advance(0.3, config)).is_equal(FogStage.Stage.NEAR)
	assert_int(FogStage.for_advance(0.6, config)).is_equal(FogStage.Stage.STAIRS)
	assert_int(FogStage.for_advance(0.75, config)).is_equal(FogStage.Stage.TRAPDOOR)
	assert_int(FogStage.for_advance(0.95, config)).is_equal(FogStage.Stage.CABIN)


func test_route_coverage_grows_but_never_closes_the_route() -> void:
	var fog := FogState.new(_config())
	var rng := _rng()
	assert_that(fog.route_segment()).is_equal(Vector2.ZERO)
	fog.start(rng)
	var small: Vector2 = fog.route_segment()
	_run(fog, 20.0, false, rng)
	var full: Vector2 = fog.route_segment()
	assert_float(full.y - full.x).is_greater(small.y - small.x)
	assert_float(full.y - full.x).is_equal_approx(0.5, 0.0001)
	assert_float(full.x).is_greater_equal(0.0)
	assert_float(full.y).is_less_equal(1.0)
