extends GdUnitTestSuite
## Entre noites só o estado persistente segue (decisão 0015): às 06:00 a simulação congela
## e o `RunState` recolhe o que importa; a noite seguinte é uma cena nova montada a partir
## dele, e começar a noite apaga o save (decisão 0014).

const GAME := "res://game/game.tscn"
const EASY := "res://config/difficulties/easy.tres"
const BATTERY_LEFT := 50.0
const BATTERY_TOLERANCE := 0.5


func test_night_end_captures_persistent_state() -> void:
	var runner := scene_runner(GAME)
	var game: Game = runner.scene()
	var night: NightDirector = runner.find_child("NightDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	var player: Player = runner.find_child("Player")
	var drowned: DrownedDirector = runner.find_child("DrownedDirector")
	var screen: NightEndScreen = runner.find_child("NightEndScreen")
	var world: Node3D = runner.find_child("World")
	night.debug_time_scale = 600.0
	lighthouse.burst_hose()
	drowned.add_drowned_point()
	drowned.add_drowned_point()
	player.flashlight.set_battery_seconds(BATTERY_LEFT)
	monitor_signals(night)
	await assert_signal(night).wait_until(5000).is_emitted("night_ended", [1])

	assert_bool(screen.visible).is_true()
	assert_int(world.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)
	assert_int(game.run.current_night).is_equal(2)
	assert_int(game.run.drowned_points).is_equal(2)
	assert_bool(game.run.hose_burst).is_true()
	assert_float(game.run.flashlight_battery_seconds).is_equal_approx(
		BATTERY_LEFT, BATTERY_TOLERANCE
	)


func test_night_starts_from_saved_run_and_consumes_save() -> void:
	var difficulty: DifficultyConfig = load(EASY)
	var run := RunState.new_run(difficulty)
	run.advance_night()
	run.drowned_points = 2
	run.hose_burst = true
	run.flashlight_battery_seconds = BATTERY_LEFT
	SaveService.write_run(run.to_dict())
	var saved := RunState.new()
	saved.from_dict(SaveService.read_run())
	# O mesmo pedido que o Continuar do menu faz, sem trocar a cena raiz do teste.
	SceneRouter._pending_run = RunRequest.new(difficulty, saved)

	var runner := scene_runner(GAME)
	var night: NightDirector = runner.find_child("NightDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	var player: Player = runner.find_child("Player")
	var drowned: DrownedDirector = runner.find_child("DrownedDirector")
	await runner.simulate_frames(2)

	assert_bool(SaveService.has_run_save()).is_false()
	assert_int(night.current_night).is_equal(2)
	assert_str(night.clock.display_text()).is_equal("20:00")
	assert_int(drowned.drowned_points).is_equal(2)
	# A mangueira segue estourada: só o gerador de emergência dá energia.
	assert_bool(lighthouse.is_hose_burst()).is_true()
	assert_bool(lighthouse.main_generator.is_running()).is_false()
	assert_bool(lighthouse.emergency_generator.is_running()).is_true()
	# O resto recomeça: casa de máquinas inteira e galão no slot.
	assert_bool(lighthouse.machine_house.is_broken()).is_false()
	assert_int(lighthouse.jerrycan.place).is_equal(Jerrycan.Place.SLOT)
	assert_float(player.flashlight.battery.remaining_seconds).is_equal_approx(
		BATTERY_LEFT, BATTERY_TOLERANCE
	)
