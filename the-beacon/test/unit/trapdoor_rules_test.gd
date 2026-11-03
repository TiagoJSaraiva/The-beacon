extends GdUnitTestSuite


func _rules() -> TrapdoorRules:
	var config := TrapdoorConfig.new()
	config.resistance_seconds = 10.0
	config.latch_relock_cooldown_seconds = 20.0
	config.reclose_cooldown_seconds = 15.0
	return TrapdoorRules.new(config)


func test_latch_toggles_only_while_closed_and_locks_the_trapdoor() -> void:
	var rules := _rules()
	rules.toggle_latch()
	assert_bool(rules.is_latched).is_true()
	assert_bool(rules.can_toggle_open()).is_false()
	rules.toggle_latch()
	assert_bool(rules.is_latched).is_false()
	assert_bool(rules.toggle_open()).is_true()
	assert_bool(rules.can_toggle_latch()).is_false()
	rules.toggle_latch()
	assert_bool(rules.is_latched).is_false()


func test_fog_unlatches_and_relock_waits_for_cooldown_after_it_leaves() -> void:
	var rules := _rules()
	rules.toggle_latch()
	rules.set_fog_present(true)
	assert_bool(rules.is_latched).is_false()
	rules.tick(100.0, false)
	assert_bool(rules.can_latch()).is_false()
	rules.set_fog_present(false)
	rules.tick(19.0, false)
	assert_bool(rules.can_latch()).is_false()
	rules.tick(1.0, false)
	assert_bool(rules.can_latch()).is_true()


func test_banging_opens_only_when_unlatched() -> void:
	var rules := _rules()
	rules.toggle_latch()
	assert_bool(rules.tick(30.0, true)).is_false()
	assert_bool(rules.is_open).is_false()
	rules.toggle_latch()
	assert_bool(rules.tick(9.0, true)).is_false()
	assert_bool(rules.tick(1.0, true)).is_true()
	assert_bool(rules.is_open).is_true()


func test_resistance_restarts_when_banging_stops() -> void:
	var rules := _rules()
	rules.tick(9.0, true)
	rules.tick(1.0, false)
	assert_bool(rules.tick(9.0, true)).is_false()
	assert_bool(rules.is_open).is_false()


func test_opened_by_the_drowned_closes_only_after_cooldown() -> void:
	var rules := _rules()
	rules.tick(10.0, true)
	assert_bool(rules.is_open).is_true()
	assert_bool(rules.toggle_open()).is_false()
	rules.tick(15.0, true)
	assert_bool(rules.toggle_open()).is_true()
	assert_bool(rules.is_open).is_false()
