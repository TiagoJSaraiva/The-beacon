extends GdUnitTestSuite
## As câmeras do mar cobrem, juntas, a rota inteira e se sobrepõem no trecho máximo do nevoeiro.

const EXTERIOR := "res://exterior/exterior.tscn"
## Altura do casco dos barcos sobre a rota.
const BOAT_HEIGHT := 1.0


func test_sea_cameras_overlap_on_the_whole_fog_segment_and_cover_the_route_ends() -> void:
	var runner := scene_runner(EXTERIOR)
	var exterior: Exterior = runner.scene()
	await runner.simulate_frames(2)
	var left: Camera3D = exterior.sea_camera_left.get_camera()
	var right: Camera3D = exterior.sea_camera_right.get_camera()

	var config := FogConfig.new()
	var half: float = config.max_route_coverage * 0.5
	for fraction: float in [config.route_center - half, config.route_center + half]:
		var point: Vector3 = _route_point(exterior.boat_path, fraction)
		assert_bool(left.is_position_in_frustum(point)).is_true()
		assert_bool(right.is_position_in_frustum(point)).is_true()

	# A câmera da esquerda mira o lado +X da rota, que é o fim da curva.
	assert_bool(left.is_position_in_frustum(_route_point(exterior.boat_path, 0.99))).is_true()
	assert_bool(right.is_position_in_frustum(_route_point(exterior.boat_path, 0.01))).is_true()
	assert_bool(left.is_position_in_frustum(_route_point(exterior.boat_path, 0.01))).is_false()
	assert_bool(right.is_position_in_frustum(_route_point(exterior.boat_path, 0.99))).is_false()


func test_sea_fog_band_at_full_growth_rises_above_the_top_of_the_sea_cameras() -> void:
	var runner := scene_runner(EXTERIOR)
	var exterior: Exterior = runner.scene()
	await runner.simulate_frames(2)
	var visuals: FogVisuals = auto_free(FogVisuals.new())
	var shape: SeaBandShape = visuals.sea_band_shape()

	var config := FogConfig.new()
	var half: float = config.max_route_coverage * 0.5
	var start: Vector3 = _route_point(exterior.boat_path, config.route_center - half, 0.0)
	var end: Vector3 = _route_point(exterior.boat_path, config.route_center + half, 0.0)
	var along: Vector3 = (end - start) * 0.5
	var side: Vector3 = along.normalized().cross(Vector3.UP)
	var extents: Vector3 = shape.half_extents(along.length(), 1.0)
	var center: Vector3 = (start + end) * 0.5

	for camera: Camera3D in [
		exterior.sea_camera_left.get_camera(), exterior.sea_camera_right.get_camera()
	]:
		# A face da frente é a mais próxima da câmera: se o topo dela fica acima da imagem, todo
		# raio da borda de cima que cruza a faixa ainda está dentro dela.
		var front: Vector3 = side * extents.z
		if (
			camera.global_position.distance_to(center - front)
			< camera.global_position.distance_to(center + front)
		):
			front = -front
		for along_fraction: float in [-1.0, 0.0, 1.0]:
			var top: Vector3 = center + along * along_fraction + Vector3.UP * extents.y + front
			assert_bool(camera.is_position_behind(top)).is_false()
			assert_float(camera.unproject_position(top).y).is_less(0.0)


## Devolve o ponto da rota na fração dada, `height` acima dela (por padrão, a altura do casco).
func _route_point(path: Path3D, fraction: float, height: float = BOAT_HEIGHT) -> Vector3:
	var curve: Curve3D = path.curve
	var point: Vector3 = path.to_global(curve.sample_baked(fraction * curve.get_baked_length()))
	return point + Vector3.UP * height
