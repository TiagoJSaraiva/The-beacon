extends GdUnitTestSuite
## Interação de duração: soltar antes do fim zera; segurar até o fim completa.

const LEVEL := "res://test/scenes/fixtures/interaction_level.tscn"


func test_release_resets_and_full_hold_completes() -> void:
	var runner := scene_runner(LEVEL)
	var target: Interactable = runner.find_child("HoldTarget")
	var ray: InteractionRay = runner.find_child("InteractionRay")
	# O runner pode gerar movimento de mouse; a mira precisa ficar parada no alvo.
	var player: Player = runner.find_child("Player")
	player.mouse_sensitivity = 0.0
	monitor_signals(target)
	monitor_signals(ray)
	await assert_signal(ray).wait_until(5000).is_emitted("focus_changed", [true])

	runner.simulate_action_press("interact")
	await await_millis(200)
	runner.simulate_action_release("interact")
	await assert_signal(ray).wait_until(1000).is_emitted("hold_progress_changed", [0.0, false])
	await assert_signal(target).wait_until(300).is_not_emitted("hold_completed")

	runner.simulate_action_press("interact")
	await assert_signal(target).wait_until(5000).is_emitted("hold_completed")
	runner.simulate_action_release("interact")


func test_outline_follows_focus() -> void:
	var runner := scene_runner(LEVEL)
	var target: Interactable = runner.find_child("HoldTarget")
	var ray: InteractionRay = runner.find_child("InteractionRay")
	var player: Player = runner.find_child("Player")
	player.mouse_sensitivity = 0.0
	var mesh := MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	runner.scene().add_child(mesh)
	var outline := OutlineHighlight.new()
	outline.interactable = target
	outline.target = mesh
	runner.scene().add_child(outline)
	assert_object(mesh.material_overlay).is_null()
	monitor_signals(ray)

	await assert_signal(ray).wait_until(5000).is_emitted("focus_changed", [true])
	assert_object(mesh.material_overlay).is_not_null()

	# Um alvo que deixa de poder ser usado sai de foco e perde o contorno.
	target.enabled = false
	await assert_signal(ray).wait_until(5000).is_emitted("focus_changed", [false])
	assert_object(mesh.material_overlay).is_null()
