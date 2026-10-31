extends GdUnitTestSuite


func _config() -> DrownedConfig:
	var config := DrownedConfig.new()
	config.perception_range = 10.0
	config.occlusion_penalty = 6.0
	return config


func test_clear_line_within_range_is_in_reach() -> void:
	assert_bool(PerceptionRules.is_in_reach(8.0, 0, _config())).is_true()


func test_obstacle_pushes_player_out_of_reach() -> void:
	assert_float(PerceptionRules.effective_distance(5.0, 1, _config())).is_equal_approx(11.0, 0.001)
	assert_bool(PerceptionRules.is_in_reach(5.0, 1, _config())).is_false()


func test_close_player_behind_one_obstacle_is_in_reach() -> void:
	assert_bool(PerceptionRules.is_in_reach(3.0, 1, _config())).is_true()
