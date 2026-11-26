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


func test_player_sees_a_headless_copy_and_cameras_see_the_whole_body() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	var body: PlayerBody = player.get_node("%Body")
	await runner.simulate_frames(5)
	var skeleton: Skeleton3D = body.find_children("*", "Skeleton3D", true, false)[0]
	var meshes: Array[Node] = skeleton.find_children("*", "MeshInstance3D", false, false)
	var full: MeshInstance3D = null
	var view: MeshInstance3D = null
	for mesh: MeshInstance3D in meshes:
		if mesh.layers == PlayerBody.PLAYER_VIEW_LAYER:
			view = mesh
		else:
			full = mesh

	assert_object(view).is_not_null()
	assert_object(full).is_not_null()
	assert_int(full.layers).is_equal(PlayerBody.WORLD_VIEW_LAYER)
	assert_int(view.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	# A cópia do jogador perde os triângulos da cabeça.
	var full_indices: int = (
		(full.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
	)
	var view_indices: int = (
		(view.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
	)
	assert_int(view_indices).is_less(full_indices)
	var camera: Camera3D = player.view_camera()
	assert_int(camera.cull_mask & PlayerBody.PLAYER_VIEW_LAYER).is_not_equal(0)
	assert_int(camera.cull_mask & PlayerBody.WORLD_VIEW_LAYER).is_equal(0)
	var security: SecurityCamera = auto_free(SecurityCamera.new())
	assert_int(security.cull_mask & PlayerBody.PLAYER_VIEW_LAYER).is_equal(0)
	assert_int(security.cull_mask & PlayerBody.WORLD_VIEW_LAYER).is_not_equal(0)
