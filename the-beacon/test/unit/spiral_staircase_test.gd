extends GdUnitTestSuite


func _staircase(radius_shrink: float) -> SpiralStaircase:
	var staircase: SpiralStaircase = auto_free(SpiralStaircase.new())
	staircase.inner_radius = 5.9
	staircase.outer_radius = 7.5
	staircase.radius_shrink = radius_shrink
	staircase.turns = 0.62
	return staircase


func _radius(point: Vector3) -> float:
	return Vector2(point.x, point.z).length()


func test_center_radius_shrinks_from_base_to_top() -> void:
	var staircase := _staircase(1.1)
	assert_float(_radius(staircase.point_at(0.0))).is_equal_approx(6.7, 0.001)
	assert_float(_radius(staircase.point_at(0.5))).is_equal_approx(6.15, 0.001)
	assert_float(_radius(staircase.point_at(1.0))).is_equal_approx(5.6, 0.001)


func test_without_shrink_radius_stays_constant() -> void:
	var staircase := _staircase(0.0)
	assert_float(_radius(staircase.point_at(0.0))).is_equal_approx(6.7, 0.001)
	assert_float(_radius(staircase.point_at(1.0))).is_equal_approx(6.7, 0.001)
