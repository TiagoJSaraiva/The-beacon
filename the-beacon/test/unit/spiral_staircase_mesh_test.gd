extends GdUnitTestSuite
## Malha dos degraus da escada em caracol: cada triângulo é de frente para o lado da normal dele.
## Com a ordem invertida, a malha ainda parece sólida, mas nenhuma luz (nem a lanterna) a ilumina.


func test_every_triangle_faces_its_normal() -> void:
	var stairs: SpiralStaircase = auto_free(SpiralStaircase.new())
	stairs.inner_radius = 4.9
	stairs.outer_radius = 6.5
	stairs.end_height = 2.0
	add_child(stairs)
	var mesh: ArrayMesh = null
	for child: Node in stairs.get_children():
		if child is MeshInstance3D:
			mesh = (child as MeshInstance3D).mesh
	assert_object(mesh).is_not_null()

	var arrays: Array = mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	assert_int(vertices.size()).is_greater(0)
	var wrong: int = 0
	for first: int in range(0, vertices.size(), 3):
		# Face da frente no Godot: a normal do `Plane` pelos três pontos aponta para fora.
		var facing: Vector3 = (
			Plane(vertices[first], vertices[first + 1], vertices[first + 2]).normal
		)
		if facing.dot(normals[first]) <= 0.0:
			wrong += 1
	assert_int(wrong).is_equal(0)
