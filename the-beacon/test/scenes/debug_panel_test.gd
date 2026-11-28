extends GdUnitTestSuite
## Painel de debug (decisão 0024): Y abre com a simulação rodando, a caixa "Pausar simulação"
## congela o `World`, e fechar devolve o `World` e não abre o menu de pausa. Na aba Tabela, a
## célula da noite em jogo muda os valores vivos (decisão 0031).

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

	pause_check.button_pressed = true
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)

	# Esc fecha o painel sem abrir o menu de pausa.
	await _tap(runner, "pause")
	assert_bool(panel.visible).is_false()
	assert_bool(pause_menu.visible).is_false()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_INHERIT)


func test_table_cell_of_current_night_changes_live_values() -> void:
	var runner := scene_runner(GAME)
	var game: Game = runner.scene()
	var grid: NightTableGrid = (
		runner.find_child("BalanceTab").find_children("*", "NightTableGrid", true, false)[0]
	)
	await runner.simulate_frames(2)
	var original: float = game.night_config.boat.crossing_seconds

	(grid.cell("boat.crossing_seconds", 2) as SpinBox).value = original + 7.0
	assert_float(game.night_config.boat.crossing_seconds).is_equal(original)
	assert_bool(BalanceService.has_unsaved_changes(&"easy")).is_true()

	(grid.cell("boat.crossing_seconds", 1) as SpinBox).value = original + 5.0
	assert_float(game.night_config.boat.crossing_seconds).is_equal(original + 5.0)
	assert_object(grid.cell("boat.crossing_seconds", 2).modulate).is_equal(
		NightTableGrid.CHANGED_COLOR
	)
	# O autoload vive durante todos os testes: esquece as edições sem gravar.
	BalanceService.discard(&"easy")


func test_night_tab_asks_for_another_night() -> void:
	# Só o painel: no jogo, o pedido recarregaria a cena no meio do teste.
	var runner := scene_runner("res://debug/debug_panel.tscn")
	var panel: DebugPanel = runner.scene()
	var night_tab: NightTab = runner.find_child("NightTab")
	await runner.simulate_frames(1)
	monitor_signals(panel)

	night_tab.night_jump_requested.emit(3)
	await assert_signal(panel).is_emitted("night_jump_requested", [3])


func test_panel_does_not_open_with_simulation_stopped() -> void:
	var runner := scene_runner(GAME)
	var panel: DebugPanel = runner.find_child("DebugPanel")
	await runner.simulate_frames(2)

	panel.enabled = false
	await _tap(runner, "debug_menu")
	assert_bool(panel.visible).is_false()


func test_threat_commands_spawn_and_remove() -> void:
	var runner := scene_runner(GAME)
	var boats: BoatDirector = runner.find_child("BoatDirector")
	var drowned: DrownedDirector = runner.find_child("DrownedDirector")
	var figurehead: FigureheadDirector = runner.find_child("FigureheadDirector")
	# A navmesh é assada um frame depois de a cena montar.
	await runner.simulate_frames(5)

	boats.spawn()
	assert_int(boats.active_boats().size()).is_equal(1)
	boats.sink_all()
	assert_int(boats.active_boats().size()).is_equal(0)
	assert_int(drowned.drowned_points).is_equal(1)

	drowned.force_enter()
	assert_bool(drowned.has_drowned_inside()).is_true()
	drowned.remove_drowned()
	assert_bool(drowned.has_drowned_inside()).is_false()

	figurehead.spawn_in_front_of_player(4.0)
	assert_int(figurehead.active_count()).is_equal(1)
	figurehead.dissolve_all()
	assert_int(figurehead.active_count()).is_equal(0)


func test_invulnerable_player_survives_and_teleports() -> void:
	var runner := scene_runner(GAME)
	var player: Player = runner.find_child("Player")
	await runner.simulate_frames(2)

	player.invulnerable = true
	player.kill(Player.CAUSE_DROWNED)
	assert_bool(player.is_dead).is_false()

	var target := Vector3(0.0, 12.0, 0.0)
	player.teleport(target)
	assert_float(player.global_position.distance_to(target)).is_less(0.01)
	assert_bool(player.is_seated).is_false()


func _tap(runner: GdUnitSceneRunner, action: String) -> void:
	runner.simulate_action_pressed(action)
	await runner.simulate_frames(2)


func test_farol_tab_bursts_and_restores_the_hose() -> void:
	var runner := scene_runner(GAME)
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	var tab: LighthouseTab = runner.find_child("LighthouseTab")
	await runner.simulate_frames(2)
	assert_bool(lighthouse.is_hose_burst()).is_false()
	assert_bool(lighthouse.lower_lights.is_powered()).is_true()

	_press(tab, "Estourar mangueira")
	await runner.simulate_frames(2)
	assert_bool(lighthouse.is_hose_burst()).is_true()
	assert_bool(lighthouse.main_generator.is_running()).is_false()
	assert_bool(lighthouse.lower_lights.is_powered()).is_false()

	# Repetir só avisa que já estava estourada.
	_press(tab, "Estourar mangueira")
	assert_bool(lighthouse.is_hose_burst()).is_true()

	_press(tab, "Consertar mangueira")
	await runner.simulate_frames(2)
	assert_bool(lighthouse.is_hose_burst()).is_false()
	assert_bool(lighthouse.main_generator.is_running()).is_true()
	assert_bool(lighthouse.lower_lights.is_powered()).is_true()


## Aperta o botão da aba com o texto dado.
func _press(tab: DebugTab, text: String) -> void:
	for button: Node in tab.find_children("*", "Button", true, false):
		if (button as Button).text == text:
			(button as Button).pressed.emit()
			return
	fail("Botão não encontrado: " + text)
