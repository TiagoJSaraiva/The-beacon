extends GdUnitTestSuite
## Alçapão: aberto, o painel fica em pé rente à parede e ainda pode ser fechado de dentro da
## cabine.

const GAME := "res://game/game.tscn"
## Em pé no piso da cabine, ao lado do vão, olhando para a parede onde o painel fica aberto.
const CABIN_SPOT := Vector3(3.6, 10.8, 0.16)
const LOOK_DOWN_DEGREES := -20.0


func test_open_panel_can_be_closed_from_the_cabin() -> void:
	var runner := scene_runner(GAME)
	var player: Player = runner.find_child("Player")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)

	var panel: Interactable = lighthouse.trapdoor.find_child("PanelInteractable")
	panel.interacted.emit()
	player.invulnerable = true
	player.teleport(CABIN_SPOT)
	# De frente para +X, onde fica a dobradiça.
	player.rotation.y = -PI / 2.0
	var head: Node3D = player.find_child("Head")
	head.rotation.x = deg_to_rad(LOOK_DOWN_DEGREES)
	await runner.simulate_frames(30)
	assert_int(lighthouse.trapdoor.state).is_equal(Trapdoor.State.OPEN)

	runner.simulate_action_press("interact")
	await runner.simulate_frames(5)
	runner.simulate_action_release("interact")
	await runner.simulate_frames(30)
	assert_int(lighthouse.trapdoor.state).is_equal(Trapdoor.State.CLOSED)
