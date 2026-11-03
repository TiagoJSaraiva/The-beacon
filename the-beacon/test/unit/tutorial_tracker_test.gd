extends GdUnitTestSuite

const CONTENT := "res://tutorial/tutorial_content.tres"


func _tracker() -> TutorialTracker:
	var ids: Array[StringName] = [&"start", &"fog", &"boat"]
	return TutorialTracker.new(ids)


func test_each_step_shows_only_the_first_time() -> void:
	var tracker: TutorialTracker = _tracker()
	assert_bool(tracker.mark_shown(&"fog")).is_true()
	assert_bool(tracker.mark_shown(&"fog")).is_false()


func test_unknown_step_is_ignored() -> void:
	var tracker: TutorialTracker = _tracker()
	assert_bool(tracker.mark_shown(&"dragon")).is_false()
	assert_int(tracker.shown_ids.size()).is_equal(0)


func test_finishes_after_all_steps() -> void:
	var tracker: TutorialTracker = _tracker()
	tracker.mark_shown(&"start")
	tracker.mark_shown(&"fog")
	assert_bool(tracker.is_finished()).is_false()
	tracker.mark_shown(&"boat")
	assert_bool(tracker.is_finished()).is_true()


func test_restore_drops_removed_steps() -> void:
	var tracker: TutorialTracker = _tracker()
	tracker.mark_shown(&"fog")
	var previous_night: Array[StringName] = tracker.shown_ids.duplicate()
	previous_night.append(&"removed_step")
	var restored: TutorialTracker = _tracker()
	restored.restore(previous_night)
	assert_array(restored.shown_ids).contains_exactly([&"fog"])
	assert_bool(restored.mark_shown(&"fog")).is_false()


func test_content_steps_are_unique_known_and_have_text() -> void:
	var content: TutorialContent = load(CONTENT)
	var ids: Array[StringName] = content.step_ids()
	assert_int(ids.size()).is_equal(TutorialDirector.KNOWN_STEPS.size())
	for step: TutorialStep in content.steps:
		assert_bool(TutorialDirector.KNOWN_STEPS.has(step.id)).is_true()
		assert_int(ids.count(step.id)).is_equal(1)
		assert_str(step.text).is_not_empty()
	assert_float(content.message_seconds).is_greater(0.0)
