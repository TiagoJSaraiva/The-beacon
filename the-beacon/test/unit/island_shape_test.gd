extends GdUnitTestSuite
## Relevo da ilha: platô plano sob o farol, praia no nível do mar, fundo abaixo dele, perfil sempre
## descendo, e a malha virada para cima.

## Raio da base do farol (parede externa no térreo) com folga.
const LIGHTHOUSE_BASE_RADIUS := 8.0


func test_plateau_is_flat_under_the_lighthouse_at_every_angle() -> void:
	var shape := IslandShape.new()
	for step in 64:
		var angle: float = TAU * step / 64.0
		for distance: float in [0.0, 4.0, LIGHTHOUSE_BASE_RADIUS]:
			assert_float(shape.height_at(distance, angle)).is_equal_approx(
				shape.plateau_height, 0.0001
			)


func test_profile_reaches_the_sea_at_the_shore_and_goes_below_it() -> void:
	var shape := IslandShape.new()
	assert_float(shape.profile(shape.shore_radius)).is_equal_approx(shape.sea_level, 0.0001)
	assert_float(shape.profile(shape.seabed_radius + 10.0)).is_equal_approx(
		shape.seabed_height, 0.0001
	)
	assert_float(shape.seabed_height).is_less(shape.sea_level)


func test_profile_never_rises_away_from_the_center() -> void:
	var shape := IslandShape.new()
	var previous: float = shape.profile(0.0)
	for step in 200:
		var height: float = shape.profile(step * 0.25)
		assert_float(height).is_less_equal(previous + 0.0001)
		previous = height


func test_mesh_faces_point_up() -> void:
	var island: Island = auto_free(Island.new())
	island.outer_radius = 10.0
	island.segments = 24
	var mesh: ArrayMesh = island.build_mesh(IslandShape.new())
	var arrays: Array = mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var wrong: int = 0
	for first: int in range(0, indices.size(), 3):
		var a: Vector3 = vertices[indices[first]]
		var b: Vector3 = vertices[indices[first + 1]]
		var c: Vector3 = vertices[indices[first + 2]]
		# Face da frente no Godot: a normal do `Plane` pelos três pontos aponta para fora.
		if Plane(a, b, c).normal.y <= 0.0:
			wrong += 1
	assert_int(wrong).is_equal(0)
