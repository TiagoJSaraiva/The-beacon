extends GdUnitTestSuite
## Movimento, pulo, queda, cadeira e derrubada do jogador numa fase plana.
## Física: só faixas de valores.

const LEVEL := "res://test/scenes/fixtures/flat_level.tscn"


func test_walk_reaches_walk_speed_and_falls_are_judged() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(10)

	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(60)
	assert_float(_horizontal_speed(player)).is_between(
		player.walk_speed * 0.8, player.walk_speed * 1.05
	)
	runner.simulate_action_release("move_forward")

	monitor_signals(player)
	player.global_position.y = 4.0
	await assert_signal(player).wait_until(3000).is_emitted("sprint_blocked_changed", [true])
	assert_bool(player.is_dead).is_false()
	# Com a corrida bloqueada, segurar a corrida só anda.
	runner.simulate_action_press("sprint")
	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(60)
	assert_float(_horizontal_speed(player)).is_less_equal(player.walk_speed * 1.05)
	runner.simulate_action_release("move_forward")
	runner.simulate_action_release("sprint")

	player.global_position.y = 9.0
	await assert_signal(player).wait_until(3000).is_emitted("died", [Player.CAUSE_FALL])
	assert_bool(player.is_dead).is_true()


func test_jump_height_is_in_range() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(10)
	var ground: float = player.global_position.y

	runner.simulate_action_press("jump")
	await runner.simulate_frames(2)
	runner.simulate_action_release("jump")
	var peak: float = ground
	for _frame: int in 120:
		await runner.simulate_frames(1)
		peak = maxf(peak, player.global_position.y)
	assert_float(peak - ground).is_between(0.6, 1.1)
	assert_float(player.global_position.y).is_equal_approx(ground, 0.05)


func test_sitting_holds_still_and_moving_stands_up() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(10)
	var seat := Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(2.0, 0.0, 1.0))

	player.sit(seat, 75.0)
	await runner.simulate_frames(10)
	assert_bool(player.is_seated).is_true()
	assert_float(player.global_position.distance_to(seat.origin)).is_less(0.05)
	assert_float(player.rotation.y).is_equal_approx(PI * 0.5, 0.01)

	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(30)
	runner.simulate_action_release("move_forward")
	assert_bool(player.is_seated).is_false()
	assert_float(player.global_position.distance_to(seat.origin)).is_greater(0.3)


func test_knockdown_holds_the_player_and_blocks_interaction_then_lets_go() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(10)
	var start: Vector3 = player.global_position

	player.knock_down(0.5)
	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(15)
	assert_bool(player.is_knocked_down).is_true()
	assert_bool(player.interaction.input_enabled).is_false()
	player.sit(Transform3D(Basis(), start + Vector3(2.0, 0.0, 0.0)), 75.0)
	assert_bool(player.is_seated).is_false()
	assert_float(player.global_position.distance_to(start)).is_less(0.05)
	await runner.simulate_frames(60)
	runner.simulate_action_release("move_forward")
	assert_bool(player.is_knocked_down).is_false()
	assert_bool(player.interaction.input_enabled).is_true()
	assert_float(player.global_position.distance_to(start)).is_greater(0.3)

	# Com os controles desligados (pausa, morte), o fim da derrubada não religa a interação.
	player.set_controls_enabled(false)
	player.knock_down(0.2)
	await runner.simulate_frames(30)
	assert_bool(player.is_knocked_down).is_false()
	assert_bool(player.interaction.input_enabled).is_false()


func _horizontal_speed(player: Player) -> float:
	return Vector2(player.velocity.x, player.velocity.z).length()
