extends GdUnitTestSuite

const HALF_SIZE := Vector2(0.6, 1.5)


func test_pushes_toward_the_nearest_edge() -> void:
	# Topo comprido em Z: perto do meio, a borda mais próxima é a do lado X.
	assert_vector(PushOffRules.edge_direction(Vector2(0.2, 0.3), HALF_SIZE)).is_equal(
		Vector2(1.0, 0.0)
	)
	assert_vector(PushOffRules.edge_direction(Vector2(-0.2, 0.3), HALF_SIZE)).is_equal(
		Vector2(-1.0, 0.0)
	)
	# Perto da ponta, a borda de Z fica mais próxima.
	assert_vector(PushOffRules.edge_direction(Vector2(0.1, 1.4), HALF_SIZE)).is_equal(
		Vector2(0.0, 1.0)
	)
	assert_vector(PushOffRules.edge_direction(Vector2(0.1, -1.4), HALF_SIZE)).is_equal(
		Vector2(0.0, -1.0)
	)


func test_center_still_pushes_somewhere() -> void:
	assert_vector(PushOffRules.edge_direction(Vector2.ZERO, HALF_SIZE)).is_equal(Vector2(1.0, 0.0))
	assert_vector(PushOffRules.edge_direction(Vector2.ZERO, Vector2(1.5, 0.6))).is_equal(
		Vector2(0.0, 1.0)
	)


func test_walking_against_the_push_is_cancelled() -> void:
	var push := Vector3(2.0, 0.0, 0.0)
	var result: Vector3 = PushOffRules.steer(Vector3(-3.5, 0.0, 0.0), push)
	assert_vector(result).is_equal_approx(push, Vector3.ONE * 0.001)


func test_walking_sideways_or_along_keeps_the_input() -> void:
	var push := Vector3(2.0, 0.0, 0.0)
	var sideways: Vector3 = PushOffRules.steer(Vector3(-1.0, 0.0, 3.0), push)
	assert_vector(sideways).is_equal_approx(Vector3(2.0, 0.0, 3.0), Vector3.ONE * 0.001)
	var along: Vector3 = PushOffRules.steer(Vector3(1.0, 0.0, 0.0), push)
	assert_vector(along).is_equal_approx(Vector3(3.0, 0.0, 0.0), Vector3.ONE * 0.001)


func test_no_push_leaves_the_input_alone() -> void:
	var input := Vector3(-1.0, 0.0, 2.0)
	assert_vector(PushOffRules.steer(input, Vector3.ZERO)).is_equal(input)
