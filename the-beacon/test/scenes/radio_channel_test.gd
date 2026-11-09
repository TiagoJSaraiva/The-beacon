extends GdUnitTestSuite
## O rádio só toca para o barco que chama na câmera do canal aberto do monitor.

const GAME := "res://game/game.tscn"
## Começo da rota (x perto de −140): só a câmera do mar à direita, canal 2, enxerga.
const BOAT_PROGRESS := 0.1


func test_radio_rings_only_while_the_calling_boat_is_on_the_open_channel() -> void:
	var runner := scene_runner(GAME)
	var fog: FogSystem = runner.find_child("FogSystem")
	var boats: BoatDirector = runner.find_child("BoatDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)

	fog.start()
	fog.state.advance = fog.state.config.near_advance
	boats.spawn()
	var boat: Boat = boats.boat_path.find_child("Boat", true, false)
	boat.passage.progress = BOAT_PROGRESS
	await runner.simulate_frames(3)
	assert_int(lighthouse.monitor.channels.current).is_equal(0)
	assert_bool(lighthouse.radio.is_ringing).is_false()

	lighthouse.monitor.next_channel()
	await runner.simulate_frames(2)
	assert_bool(lighthouse.radio.is_ringing).is_false()

	lighthouse.monitor.next_channel()
	await runner.simulate_frames(2)
	assert_bool(lighthouse.radio.is_ringing).is_true()

	lighthouse.monitor.next_channel()
	await runner.simulate_frames(2)
	assert_bool(lighthouse.radio.is_ringing).is_false()
