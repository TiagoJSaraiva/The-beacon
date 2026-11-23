extends GdUnitTestSuite


func test_box_roof_slopes_at_the_requested_angle() -> void:
	var points: PackedVector3Array = RidgeRoof.over_box_top(1.6, 0.8, 60.0)
	assert_int(points.size()).is_equal(6)
	var rise: float = _top(points)
	assert_float(rad_to_deg(atan2(rise, 0.4))).is_equal_approx(60.0, 0.01)


func test_box_roof_covers_the_whole_top_and_follows_the_longer_side() -> void:
	var along_x: PackedVector3Array = RidgeRoof.over_box_top(1.6, 0.8, 60.0)
	assert_vector(_extent(along_x)).is_equal_approx(Vector3(1.6, 0.0, 0.8), Vector3.ONE * 0.001)
	var along_z: PackedVector3Array = RidgeRoof.over_box_top(0.8, 1.6, 60.0)
	assert_vector(_extent(along_z)).is_equal_approx(Vector3(0.8, 0.0, 1.6), Vector3.ONE * 0.001)
	# Cumeeira no lado comprido: o telhado sobe pela metade do lado curto.
	assert_float(_top(along_z)).is_equal_approx(_top(along_x), 0.001)


## Devolve a maior altura entre os pontos.
func _top(points: PackedVector3Array) -> float:
	var top: float = -INF
	for point: Vector3 in points:
		top = maxf(top, point.y)
	return top


## Devolve o tamanho da base (X e Z) dos pontos; Y fica em zero.
func _extent(points: PackedVector3Array) -> Vector3:
	var low := Vector3.INF
	var high := -Vector3.INF
	for point: Vector3 in points:
		low = low.min(point)
		high = high.max(point)
	var size: Vector3 = high - low
	size.y = 0.0
	return size
