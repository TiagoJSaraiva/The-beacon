extends GdUnitTestSuite


func _approach() -> DrownedApproach:
	var config := DrownedConfig.new()
	config.approach_base_per_second = 0.01
	config.approach_per_point_per_second = 0.01
	config.approach_recede_per_second = 0.05
	return DrownedApproach.new(config)


func test_rises_only_with_fog_inside_and_points() -> void:
	var approach := _approach()
	approach.tick(10.0, true, 0)
	assert_float(approach.level).is_equal(0.0)
	approach.tick(10.0, false, 3)
	assert_float(approach.level).is_equal(0.0)
	approach.tick(10.0, true, 1)
	assert_float(approach.level).is_equal_approx(0.2, 0.0001)


func test_more_points_approach_faster() -> void:
	var one := _approach()
	var three := _approach()
	one.tick(10.0, true, 1)
	three.tick(10.0, true, 3)
	assert_float(three.level).is_equal_approx(0.4, 0.0001)
	assert_float(three.level).is_greater(one.level)


func test_falls_back_when_the_fog_leaves() -> void:
	var approach := _approach()
	approach.tick(20.0, true, 1)
	approach.tick(4.0, false, 1)
	assert_float(approach.level).is_equal_approx(0.2, 0.0001)
	approach.tick(100.0, false, 1)
	assert_float(approach.level).is_equal(0.0)


func test_enters_once_when_full() -> void:
	var approach := _approach()
	assert_bool(approach.tick(49.0, true, 1)).is_false()
	assert_bool(approach.tick(2.0, true, 1)).is_true()
	assert_bool(approach.has_entered).is_true()
	assert_bool(approach.tick(100.0, true, 5)).is_false()
