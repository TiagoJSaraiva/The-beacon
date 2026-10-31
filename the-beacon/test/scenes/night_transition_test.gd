extends GdUnitTestSuite
## Fim de noite: a simulação congela, a tela aparece e, ao continuar, a noite seguinte
## começa às 20:00 com recursos e danos mantidos.

const GAME := "res://game/game.tscn"


func test_night_ends_and_next_night_keeps_state() -> void:
	var runner := scene_runner(GAME)
	var game: Game = runner.scene()
	var night: NightDirector = runner.find_child("NightDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	var screen: NightEndScreen = runner.find_child("NightEndScreen")
	var world: Node3D = runner.find_child("World")
	night.debug_time_scale = 600.0
	lighthouse.generator.break_down()
	monitor_signals(night)
	await assert_signal(night).wait_until(5000).is_emitted("night_ended", [1])

	assert_bool(screen.visible).is_true()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)

	screen._on_continue_button_pressed()
	assert_int(game.run.current_night).is_equal(2)
	assert_str(night.clock.display_text()).is_equal("20:00")
	assert_bool(lighthouse.generator.state.is_broken).is_true()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_INHERIT)
