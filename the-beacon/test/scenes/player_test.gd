extends GdUnitTestSuite
## Movimento e queda do jogador numa fase plana. Física: só faixas de valores.

const LEVEL := "res://test/scenes/fixtures/flat_level.tscn"


func test_walk_reaches_walk_speed_and_falls_are_judged() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(10)

	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(60)
	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	assert_float(speed).is_between(player.walk_speed * 0.8, player.walk_speed * 1.05)
	runner.simulate_action_release("move_forward")

	monitor_signals(player)
	player.global_position.y = 4.0
	await assert_signal(player).wait_until(3000).is_emitted("slowed_changed", [true])
	assert_bool(player.is_dead).is_false()

	player.global_position.y = 9.0
	await assert_signal(player).wait_until(3000).is_emitted("died", [Player.CAUSE_FALL])
	assert_bool(player.is_dead).is_true()
