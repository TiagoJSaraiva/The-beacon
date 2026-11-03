extends GdUnitTestSuite
## Com o nevoeiro tomando o farol, uma carranca surge longe do jogador; com ele perto e à
## vista, ela pula e cega.

const GAME := "res://game/game.tscn"


func test_figurehead_spawns_away_and_blinds_up_close() -> void:
	var runner := scene_runner(GAME)
	var fog: FogSystem = runner.find_child("FogSystem")
	var director: FigureheadDirector = runner.find_child("FigureheadDirector")
	var player: Player = runner.find_child("Player")
	# A navmesh é assada depois do primeiro frame.
	await runner.simulate_frames(10)

	monitor_signals(director)
	fog.start()
	fog.state.advance = 1.0
	await assert_signal(director).wait_until(2000).is_emitted("appeared")
	var figurehead: Figurehead = director.find_child("Figurehead", true, false)
	assert_object(figurehead).is_not_null()
	var distance: float = figurehead.global_position.distance_to(player.eye_transform().origin)
	assert_float(distance).is_greater_equal(director.tracker.config.min_spawn_distance)

	var eye: Transform3D = player.eye_transform()
	figurehead.global_position = player.global_position - eye.basis.z.slide(Vector3.UP) * 2.0
	await assert_signal(director).wait_until(2000).is_emitted(
		"player_blinded", [director.tracker.config.blind_seconds]
	)
