extends GdUnitTestSuite
## Escada de mão: o jogador sobe do patamar até o piso da cabine, pelo alçapão aberto, e nenhuma
## peça da escada passa do topo.
## Física: só faixas de valores.

const GAME := "res://game/game.tscn"
const LADDER_FOOT := Vector3(4.7, 8.45, 0.3)
const CABIN_FLOOR := 10.8


func test_player_climbs_from_the_landing_to_the_cabin() -> void:
	var runner := scene_runner(GAME)
	var player: Player = runner.find_child("Player")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)

	# O painel só abre por cima; o teste dispara o interativo direto.
	var panel: Interactable = lighthouse.trapdoor.find_child("PanelInteractable")
	panel.interacted.emit()
	player.invulnerable = true
	player.teleport(LADDER_FOOT)
	# De frente para +Z, onde fica a escada.
	player.rotation.y = PI
	await runner.simulate_frames(10)

	runner.simulate_action_press("move_forward")
	await runner.simulate_frames(240)
	runner.simulate_action_release("move_forward")
	await runner.simulate_frames(30)
	assert_float(player.global_position.y).is_between(CABIN_FLOOR - 0.1, CABIN_FLOOR + 0.2)
	assert_float(player.global_position.z).is_greater(1.1)


func test_ladder_parts_stay_below_its_top() -> void:
	var ladder: Ladder = auto_free(load("res://lighthouse/ladder.tscn").instantiate())
	add_child(ladder)
	var meshes: Array[Node] = ladder.find_children("*", "MeshInstance3D", true, false)
	assert_int(meshes.size()).is_greater(0)
	for node: Node in meshes:
		var mesh := node as MeshInstance3D
		var top: float = mesh.position.y + mesh.get_aabb().end.y
		assert_float(top).is_less_equal(ladder.height + 0.001)
