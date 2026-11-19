extends GdUnitTestSuite

const DESCEND := deg_to_rad(30.0)
const LEVEL_PITCH := 0.0
const LOOKING_DOWN := -deg_to_rad(50.0)


func test_forward_climbs_up_and_back_climbs_down_looking_ahead() -> void:
	assert_float(LadderRules.climb_direction(-1.0, LEVEL_PITCH, DESCEND)).is_equal(1.0)
	assert_float(LadderRules.climb_direction(1.0, LEVEL_PITCH, DESCEND)).is_equal(-1.0)


func test_looking_down_forward_climbs_down() -> void:
	assert_float(LadderRules.climb_direction(-1.0, LOOKING_DOWN, DESCEND)).is_equal(-1.0)
	assert_float(LadderRules.climb_direction(1.0, LOOKING_DOWN, DESCEND)).is_equal(1.0)


func test_without_input_holds_still() -> void:
	assert_float(LadderRules.climb_direction(0.0, LOOKING_DOWN, DESCEND)).is_equal(0.0)
	assert_float(LadderRules.vertical_speed(0.0, 2.0, 9.0, 10.9, false)).is_equal(0.0)


func test_half_tilted_stick_climbs_slower() -> void:
	var direction: float = LadderRules.climb_direction(-0.5, LEVEL_PITCH, DESCEND)
	assert_float(LadderRules.vertical_speed(direction, 2.0, 9.0, 10.9, false)).is_equal(1.0)


func test_stops_rising_at_the_top_but_can_descend() -> void:
	assert_float(LadderRules.vertical_speed(1.0, 2.0, 10.9, 10.9, false)).is_equal(0.0)
	assert_float(LadderRules.vertical_speed(-1.0, 2.0, 10.9, 10.9, false)).is_equal(-2.0)


func test_walking_away_on_the_floor_does_not_lift() -> void:
	assert_float(LadderRules.vertical_speed(1.0, 2.0, 8.4, 10.9, true)).is_equal(0.0)
	assert_float(LadderRules.vertical_speed(-1.0, 2.0, 8.4, 10.9, true)).is_equal(-2.0)


func test_without_away_drops_only_the_outward_part() -> void:
	var away := Vector3(0.0, 0.0, -1.0)
	var outward_and_side := Vector3(0.5, 0.0, -1.0)
	assert_vector(LadderRules.without_away(outward_and_side, away)).is_equal_approx(
		Vector3(0.5, 0.0, 0.0), Vector3.ONE * 0.001
	)
	var toward := Vector3(0.0, 0.0, 1.0)
	assert_vector(LadderRules.without_away(toward, away)).is_equal(toward)
