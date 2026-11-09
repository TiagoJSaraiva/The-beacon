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


## Devolve o ponto da rota na fração dada, na altura do casco.
func _route_point(path: Path3D, fraction: float) -> Vector3:
	var curve: Curve3D = path.curve
	var point: Vector3 = path.to_global(curve.sample_baked(fraction * curve.get_baked_length()))
	return point + Vector3.UP * BOAT_HEIGHT
