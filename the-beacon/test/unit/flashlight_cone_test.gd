extends GdUnitTestSuite


func test_point_ahead_inside_range_is_lit() -> void:
	var lit: bool = FlashlightCone.contains(
		Vector3.ZERO, Vector3.FORWARD, Vector3(0, 0, -5), 10.0, 20.0
	)
	assert_bool(lit).is_true()


func test_point_beyond_range_is_dark() -> void:
	var lit: bool = FlashlightCone.contains(
		Vector3.ZERO, Vector3.FORWARD, Vector3(0, 0, -11), 10.0, 20.0
	)
	assert_bool(lit).is_false()


func test_point_outside_angle_is_dark() -> void:
	# 45° fora do eixo, com cone de 20°.
	var lit: bool = FlashlightCone.contains(
		Vector3.ZERO, Vector3.FORWARD, Vector3(3, 0, -3), 10.0, 20.0
	)
	assert_bool(lit).is_false()
