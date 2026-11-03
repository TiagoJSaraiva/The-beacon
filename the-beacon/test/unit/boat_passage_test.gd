extends GdUnitTestSuite

const CROSSING := 12.0
const STEP := 0.1


func _run(passage: BoatPassage, seconds: float, fog: Vector2) -> void:
	for _step: int in roundi(seconds / STEP):
		passage.tick(STEP, fog.x, fog.y)


func test_without_fog_crosses_without_calling() -> void:
	var passage := BoatPassage.new(CROSSING)
	assert_bool(passage.is_calling(0.0, 0.0)).is_false()
	_run(passage, CROSSING + 0.5, Vector2.ZERO)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.PASSED)


func test_entering_the_fog_sinks_at_once() -> void:
	var passage := BoatPassage.new(CROSSING)
	var fog := Vector2(0.5, 0.7)
	assert_bool(passage.is_calling(fog.x, fog.y)).is_true()
	_run(passage, CROSSING * 0.45, fog)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.CROSSING)
	_run(passage, CROSSING * 0.1, fog)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.SANK)
	assert_float(passage.progress).is_between(0.5, 0.52)


func test_warning_with_lit_beam_diverts() -> void:
	var passage := BoatPassage.new(CROSSING)
	passage.answer(true)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.DIVERTED)
	assert_bool(passage.is_calling(0.5, 0.7)).is_false()


func test_answering_with_dark_beam_stops_the_call_but_not_the_boat() -> void:
	var passage := BoatPassage.new(CROSSING)
	var fog := Vector2(0.5, 0.7)
	passage.answer(false)
	assert_bool(passage.is_calling(fog.x, fog.y)).is_false()
	_run(passage, CROSSING, fog)
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.SANK)


func test_stops_calling_once_past_the_fog() -> void:
	var passage := BoatPassage.new(CROSSING)
	_run(passage, CROSSING * 0.6, Vector2.ZERO)
	assert_bool(passage.is_calling(0.2, 0.4)).is_false()
	_run(passage, CROSSING, Vector2(0.2, 0.4))
	assert_int(passage.outcome).is_equal(BoatPassage.Outcome.PASSED)
