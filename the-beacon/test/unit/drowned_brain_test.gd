extends GdUnitTestSuite


func _brain() -> DrownedBrain:
	var config := DrownedConfig.new()
	config.tire_seconds = 10.0
	config.rest_seconds = 5.0
	return DrownedBrain.new(config)


func _at_trapdoor(brain: DrownedBrain, senses: DrownedSenses) -> void:
	senses.arrived = true
	brain.update(0.1, senses)


func test_starts_heading_to_the_trapdoor_and_bangs_on_arrival() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	assert_int(brain.target()).is_equal(DrownedBrain.Target.TRAPDOOR_BELOW)
	brain.update(0.1, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_TRAPDOOR)
	_at_trapdoor(brain, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.BANG_TRAPDOOR)
	assert_bool(brain.is_banging()).is_true()


func test_player_in_reach_is_chased_and_killed_on_touch() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	senses.player_in_reach = true
	brain.update(0.1, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	assert_int(brain.target()).is_equal(DrownedBrain.Target.PLAYER)
	senses.player_in_kill_range = true
	assert_int(brain.update(0.1, senses)).is_equal(DrownedBrain.Effect.KILL)


func test_losing_the_player_sends_him_back_to_the_trapdoor() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	senses.player_in_reach = true
	brain.update(0.1, senses)
	senses.player_in_reach = false
	brain.update(0.1, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_TRAPDOOR)


func test_latched_trapdoor_tires_him_then_he_rests_and_returns() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	senses.trapdoor_latched = true
	_at_trapdoor(brain, senses)
	brain.update(9.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.BANG_TRAPDOOR)
	brain.update(1.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.REST)
	assert_int(brain.target()).is_equal(DrownedBrain.Target.REST_SPOT)
	senses.arrived = true
	brain.update(4.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.REST)
	brain.update(1.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_TRAPDOOR)


func test_unlatched_trapdoor_keeps_him_banging() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	_at_trapdoor(brain, senses)
	brain.update(100.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.BANG_TRAPDOOR)


func test_open_trapdoor_means_chasing_even_out_of_reach() -> void:
	var brain := _brain()
	var senses := DrownedSenses.new()
	_at_trapdoor(brain, senses)
	senses.trapdoor_state = Trapdoor.State.OPEN
	brain.update(0.1, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	brain.update(5.0, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	senses.trapdoor_state = Trapdoor.State.CLOSED
	brain.update(0.1, senses)
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_TRAPDOOR)
