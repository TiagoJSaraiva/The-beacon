extends GdUnitTestSuite

const FOOT := Vector3(4.7, 8.4, 0.45)
const TOP := Vector3(4.7, 10.8, 1.6)
const TOLERANCE := Vector3(0.001, 0.001, 0.001)


func test_going_up_climbs_straight_then_walks_onto_the_floor() -> void:
	var ladder := LadderTraversal.new(FOOT, TOP)
	assert_vector(ladder.advance(1.2, true)).is_equal_approx(Vector3(4.7, 9.6, 0.45), TOLERANCE)
	assert_vector(ladder.advance(1.2, true)).is_equal_approx(Vector3(4.7, 10.8, 0.45), TOLERANCE)
	assert_bool(ladder.is_finished(true)).is_false()
	assert_vector(ladder.advance(5.0, true)).is_equal_approx(TOP, TOLERANCE)
	assert_bool(ladder.is_finished(true)).is_true()


func test_going_down_walks_to_the_hole_then_descends() -> void:
	var ladder := LadderTraversal.new(TOP, FOOT)
	assert_vector(ladder.advance(1.15, true)).is_equal_approx(Vector3(4.7, 10.8, 0.45), TOLERANCE)
	assert_vector(ladder.advance(5.0, true)).is_equal_approx(FOOT, TOLERANCE)
	assert_bool(ladder.is_finished(true)).is_true()


func test_closed_passage_sends_the_climber_back_to_the_entry() -> void:
	var ladder := LadderTraversal.new(FOOT, TOP)
	ladder.advance(1.0, true)
	assert_float(ladder.advance(0.4, false).y).is_equal_approx(9.0, 0.001)
	assert_bool(ladder.is_finished(false)).is_false()
	assert_vector(ladder.advance(5.0, false)).is_equal_approx(FOOT, TOLERANCE)
	assert_bool(ladder.is_finished(false)).is_true()


func test_closed_passage_does_not_stop_the_descent() -> void:
	var ladder := LadderTraversal.new(TOP, FOOT)
	ladder.advance(1.0, true)
	ladder.advance(5.0, false)
	assert_bool(ladder.is_finished(false)).is_true()
	assert_vector(ladder.position()).is_equal_approx(FOOT, TOLERANCE)
