extends GdUnitTestSuite
## Corpo do jogador: a animação e as pernas seguem o movimento, e sentar e ser derrubado trocam
## a pose. Só faixas de valores (física e animação).

const LEVEL := "res://test/scenes/fixtures/flat_level.tscn"


func test_legs_follow_the_movement_direction() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	var body: PlayerBody = player.get_node("%Body")
	await runner.simulate_frames(10)
	assert_str(body.current_state()).is_equal("idle")

	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(60)
	assert_str(body.current_state()).is_equal("jog")
	assert_float(absf(body.leg_yaw())).is_less(0.1)
	runner.simulate_action_release("move_forward")

	runner.simulate_action_press("move_right")
	await runner.simulate_frames(90)
	assert_float(body.leg_yaw()).is_between(1.2, PI / 2.0 + 0.01)
	runner.simulate_action_release("move_right")

	await runner.simulate_frames(90)
	assert_str(body.current_state()).is_equal("idle")


func test_sitting_and_knockdown_change_the_pose() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	var body: PlayerBody = player.get_node("%Body")
	await runner.simulate_frames(10)

	player.sit(Transform3D(Basis.IDENTITY, player.global_position), 75.0)
	await runner.simulate_frames(5)
	assert_str(body.current_state()).is_equal("sit")

	player.knock_down(1.0)
	await runner.simulate_frames(5)
	assert_str(body.current_state()).is_equal("kneel")
