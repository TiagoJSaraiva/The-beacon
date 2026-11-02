extends GdUnitTestSuite
## Salvar no meio da noite e restaurar devolve horário, recursos, danos, posição do jogador e
## o barco em andamento. O save passa por JSON, como no arquivo de verdade.

const GAME := "res://game/game.tscn"
const SAVED_POSITION := Vector3(-1.0, 0.05, 1.0)
const POSITION_TOLERANCE := 0.3
const CLOCK_TOLERANCE_SECONDS := 1.0
const FUEL_TOLERANCE := 1.0


func test_restore_brings_back_mid_night_state() -> void:
	var runner := scene_runner(GAME)
	var game: Game = runner.scene()
	var night: NightDirector = runner.find_child("NightDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	var player: Player = runner.find_child("Player")
	var boats: BoatDirector = runner.find_child("BoatDirector")
	var drowned: DrownedDirector = runner.find_child("DrownedDirector")
	var snapshot: RunSnapshot = runner.find_child("RunSnapshot")
	await runner.simulate_frames(2)

	var saved_elapsed: float = night.clock.duration_seconds() * 0.5
	night.clock.elapsed_seconds = saved_elapsed
	lighthouse.entrance_door.break_door()
	lighthouse.generator.state.fuel = 10.0
	drowned.add_drowned_point()
	player.global_position = SAVED_POSITION
	boats.spawn()
	var saved: Dictionary = JSON.parse_string(JSON.stringify(snapshot.capture(game.run)))

	night.clock.reset()
	lighthouse.entrance_door.repair()
	lighthouse.generator.state.fuel = lighthouse.generator.state.config.generator_capacity
	drowned.drowned_points = 0
	player.global_position = Vector3(-2.5, 9.05, 1.5)
	boats.clear()
	snapshot.restore(saved, game.run)

	assert_float(night.clock.elapsed_seconds).is_equal_approx(
		saved_elapsed, CLOCK_TOLERANCE_SECONDS
	)
	assert_bool(night.is_running).is_true()
	assert_bool(lighthouse.entrance_door.is_broken).is_true()
	assert_float(lighthouse.generator.state.fuel).is_equal_approx(10.0, FUEL_TOLERANCE)
	assert_int(drowned.drowned_points).is_equal(1)
	assert_float(player.global_position.distance_to(SAVED_POSITION)).is_less(POSITION_TOLERANCE)
	assert_bool(boats.can_spawn()).is_false()
	assert_bool(lighthouse.radio.is_ringing).is_true()
