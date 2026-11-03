extends GdUnitTestSuite

const STAIRS_FROM := 3.2
const CABIN_FROM := 8.8


func test_area_by_height() -> void:
	assert_int(FigureheadSpawnRules.area_for_height(0.0, STAIRS_FROM, CABIN_FROM)).is_equal(
		FigureheadSpawnRules.Area.GROUND_FLOOR
	)
	assert_int(FigureheadSpawnRules.area_for_height(5.0, STAIRS_FROM, CABIN_FROM)).is_equal(
		FigureheadSpawnRules.Area.STAIRS
	)
	assert_int(FigureheadSpawnRules.area_for_height(9.0, STAIRS_FROM, CABIN_FROM)).is_equal(
		FigureheadSpawnRules.Area.CABIN
	)


func test_only_areas_already_taken_by_fog() -> void:
	var ground := FigureheadSpawnRules.Area.GROUND_FLOOR
	var cabin := FigureheadSpawnRules.Area.CABIN
	assert_bool(FigureheadSpawnRules.is_fogged(ground, FogStage.Stage.NEAR)).is_false()
	assert_bool(FigureheadSpawnRules.is_fogged(ground, FogStage.Stage.GROUND_FLOOR)).is_true()
	assert_bool(FigureheadSpawnRules.is_fogged(cabin, FogStage.Stage.TRAPDOOR)).is_false()
	assert_bool(FigureheadSpawnRules.is_fogged(cabin, FogStage.Stage.CABIN)).is_true()


func test_point_must_be_out_of_view_and_far() -> void:
	# Olho na origem, olhando para -Z, campo de 60° para cada lado, mínimo de 6 m.
	assert_bool(_hidden_and_far(Vector3(0, 0, 8))).is_true()
	assert_bool(_hidden_and_far(Vector3(0, 0, 3))).is_false()
	assert_bool(_hidden_and_far(Vector3(1, 0, -8))).is_false()


func _hidden_and_far(point: Vector3) -> bool:
	return FigureheadSpawnRules.is_hidden_and_far(point, Vector3.ZERO, Vector3.FORWARD, 60.0, 6.0)
