extends GdUnitTestSuite
## Painel de debug (decisão 0024): Y abre com a simulação rodando, a caixa "Pausar simulação"
## congela o `World`, e fechar devolve o `World` e não abre o menu de pausa.

const GAME := "res://game/game.tscn"


func test_panel_opens_pauses_world_and_closes() -> void:
	var runner := scene_runner(GAME)
	var panel: DebugPanel = runner.find_child("DebugPanel")
	var pause_menu: PauseMenu = runner.find_child("PauseMenu")
	var world: Node3D = runner.find_child("World")
	var pause_check: CheckBox = runner.find_child("PauseCheck")
	await runner.simulate_frames(2)

	await _tap(runner, "debug_menu")
	assert_bool(panel.visible).is_true()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_INHERIT)
	var readout: Label = runner.find_child("Readout")
	assert_str(readout.text).contains("Noite 1 · 20:00")
	# Uma seção por parte da dificuldade, montada com a dificuldade da noite.
	var balance: BalanceTab = runner.find_child("BalanceTab")
	assert_int(balance.find_children("*", "ConfigEditor", true, false).size()).is_greater(10)

	pause_check.button_pressed = true
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)

	# Esc fecha o painel sem abrir o menu de pausa.
	await _tap(runner, "pause")
	assert_bool(panel.visible).is_false()
	assert_bool(pause_menu.visible).is_false()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_INHERIT)


func test_panel_does_not_open_with_simulation_stopped() -> void:
	var runner := scene_runner(GAME)
	var panel: DebugPanel = runner.find_child("DebugPanel")
	await runner.simulate_frames(2)

	panel.enabled = false
	await _tap(runner, "debug_menu")
	assert_bool(panel.visible).is_false()


func _tap(runner: GdUnitSceneRunner, action: String) -> void:
	runner.simulate_action_pressed(action)
	await runner.simulate_frames(2)
