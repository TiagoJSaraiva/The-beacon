extends GdUnitTestSuite

const LIMIT := 75.0 * PI / 180.0


func test_yaw_inside_limit_is_kept() -> void:
	var yaw: float = deg_to_rad(40.0)
	assert_float(SeatRules.clamp_yaw(yaw, 0.0, LIMIT)).is_equal_approx(yaw, 0.0001)


func test_yaw_beyond_limit_stops_at_the_limit_on_each_side() -> void:
	assert_float(SeatRules.clamp_yaw(deg_to_rad(120.0), 0.0, LIMIT)).is_equal_approx(LIMIT, 0.0001)
	assert_float(SeatRules.clamp_yaw(deg_to_rad(-120.0), 0.0, LIMIT)).is_equal_approx(
		-LIMIT, 0.0001
	)


func test_limit_follows_the_shortest_angle_across_full_turns() -> void:
	var center: float = deg_to_rad(170.0)
	# -170° está a 20° de 170° passando por 180°, dentro do limite.
	var yaw: float = deg_to_rad(-170.0)
	var expected: float = center + deg_to_rad(20.0)
	assert_float(SeatRules.clamp_yaw(yaw, center, LIMIT)).is_equal_approx(expected, 0.0001)
	var turned: float = center + TAU * 2.0 + deg_to_rad(100.0)
	assert_float(SeatRules.clamp_yaw(turned, center, LIMIT)).is_equal_approx(center + LIMIT, 0.0001)
