extends GdUnitTestSuite


func _shape() -> SeaBandShape:
	var shape := SeaBandShape.new()
	shape.max_half_height = 60.0
	shape.max_half_depth = 45.0
	shape.min_half_extent = 0.5
	return shape


func test_height_starts_equal_to_the_length() -> void:
	var extents: Vector3 = _shape().half_extents(5.0, 0.0)
	assert_float(extents.y).is_equal_approx(5.0, 0.001)


func test_height_reaches_the_maximum_at_full_growth_regardless_of_length() -> void:
	var shape: SeaBandShape = _shape()
	assert_float(shape.half_extents(28.0, 1.0).y).is_equal_approx(60.0, 0.001)
	assert_float(shape.half_extents(5.0, 1.0).y).is_equal_approx(60.0, 0.001)


func test_height_rises_with_growth() -> void:
	var shape: SeaBandShape = _shape()
	var previous: float = 0.0
	for growth: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
		var height: float = shape.half_extents(10.0, growth).y
		assert_float(height).is_greater(previous)
		previous = height


func test_growth_outside_zero_to_one_is_clamped() -> void:
	var shape: SeaBandShape = _shape()
	assert_float(shape.half_extents(10.0, 2.0).y).is_equal_approx(60.0, 0.001)
	assert_float(shape.half_extents(10.0, -1.0).y).is_equal_approx(10.0, 0.001)


func test_length_and_depth_follow_the_route_segment() -> void:
	var extents: Vector3 = _shape().half_extents(28.0, 1.0)
	assert_float(extents.x).is_equal_approx(28.0, 0.001)
	assert_float(extents.z).is_equal_approx(28.0, 0.001)


func test_depth_is_capped() -> void:
	assert_float(_shape().half_extents(80.0, 1.0).z).is_equal_approx(45.0, 0.001)


func test_tiny_segment_keeps_a_minimum_size() -> void:
	var extents: Vector3 = _shape().half_extents(0.0, 0.0)
	assert_float(extents.x).is_equal_approx(0.5, 0.001)
	assert_float(extents.y).is_equal_approx(0.5, 0.001)
	assert_float(extents.z).is_equal_approx(0.5, 0.001)
