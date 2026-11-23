extends GdUnitTestSuite
## Divisão da escada em caracol em degraus soltos: quantidade, trecho de cada um e vão entre eles.


func test_step_count_follows_the_rise() -> void:
	assert_int(SpiralStepLayout.step_count(8.4, 0.16)).is_equal(53)
	assert_int(SpiralStepLayout.step_count(0.05, 0.16)).is_equal(1)
	assert_int(SpiralStepLayout.step_count(8.4, 0.0)).is_equal(1)


func test_steps_are_centered_in_their_slice_with_a_gap() -> void:
	var count: int = 10
	var first: Vector2 = SpiralStepLayout.step_range(0, count, 0.7)
	var second: Vector2 = SpiralStepLayout.step_range(1, count, 0.7)
	assert_float(first.x).is_equal_approx(0.015, 0.0001)
	assert_float(first.y).is_equal_approx(0.085, 0.0001)
	assert_float(second.x - first.y).is_equal_approx(0.03, 0.0001)
	assert_float(SpiralStepLayout.step_center(0, count)).is_equal_approx(0.05, 0.0001)


func test_full_fill_closes_the_gap_and_last_step_ends_at_the_top() -> void:
	var count: int = 4
	assert_float(SpiralStepLayout.step_range(0, count, 1.0).y).is_equal_approx(
		SpiralStepLayout.step_range(1, count, 1.0).x, 0.0001
	)
	assert_float(SpiralStepLayout.step_range(count - 1, count, 1.0).y).is_equal_approx(1.0, 0.0001)
