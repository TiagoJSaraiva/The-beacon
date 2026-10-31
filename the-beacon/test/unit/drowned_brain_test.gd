extends GdUnitTestSuite


func _brain(chase_threshold: float = 3.0) -> DrownedBrain:
	var config := DrownedConfig.new()
	config.door_break_seconds = 2.0
	config.sabotage_seconds = 2.0
	config.bang_seconds = 5.0
	var threat_config := ThreatConfig.new()
	threat_config.chase_threat_threshold = chase_threshold
	return DrownedBrain.new(config, threat_config)


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	return rng


func _senses(threat: float = 1.0, door_broken: bool = false) -> DrownedSenses:
	var senses := DrownedSenses.new()
	senses.threat = threat
	senses.door_broken = door_broken
	return senses


func test_intact_door_is_always_broken_first() -> void:
	var brain := _brain()
	var senses := _senses(10.0)
	brain.start(senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.APPROACH_DOOR)
	senses.arrived = true
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.BREAK_DOOR)
	assert_int(brain.update(2.0, senses, _rng())).is_equal(DrownedBrain.Effect.BREAK_DOOR)


func test_player_out_of_reach_with_intact_door_is_ignored() -> void:
	var brain := _brain()
	var senses := _senses()
	brain.start(senses, _rng())
	senses.player_in_reach = true
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.APPROACH_DOOR)


func test_low_threat_sabotages_then_leaves() -> void:
	var brain := _brain()
	var senses := _senses(1.0, true)
	brain.start(senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_SABOTAGE)
	senses.arrived = true
	brain.update(0.1, senses, _rng())
	var effect: DrownedBrain.Effect = brain.update(2.0, senses, _rng())
	assert_array([DrownedBrain.Effect.DAMAGE_HOSE, DrownedBrain.Effect.DAMAGE_GENERATOR]).contains(
		[effect]
	)
	assert_int(brain.state).is_equal(DrownedBrain.State.LEAVE)
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.GONE)


func test_sabotage_skips_what_is_already_broken() -> void:
	var brain := _brain()
	var senses := _senses(1.0, true)
	senses.generator_broken = true
	brain.start(senses, _rng())
	assert_int(brain.target()).is_equal(DrownedBrain.Target.HOSE)


func test_everything_broken_means_leaving() -> void:
	var brain := _brain()
	var senses := _senses(1.0, true)
	senses.generator_broken = true
	senses.hose_broken = true
	brain.start(senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.LEAVE)


func test_high_threat_goes_to_trapdoor_and_bangs() -> void:
	var brain := _brain()
	var senses := _senses(3.0, true)
	brain.start(senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_TRAPDOOR)
	senses.arrived = true
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.BANG_TRAPDOOR)
	brain.update(5.0, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.LEAVE)


func test_open_trapdoor_means_chase_until_kill() -> void:
	var brain := _brain()
	var senses := _senses(3.0, true)
	brain.start(senses, _rng())
	senses.arrived = true
	senses.trapdoor_state = Trapdoor.State.OPEN
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	senses.player_in_reach = false
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	senses.player_in_reach = true
	senses.player_in_kill_range = true
	assert_int(brain.update(0.1, senses, _rng())).is_equal(DrownedBrain.Effect.KILL)


func test_player_in_reach_is_always_the_target() -> void:
	var brain := _brain()
	var senses := _senses(1.0, true)
	brain.start(senses, _rng())
	senses.player_in_reach = true
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.CHASE)
	assert_int(brain.target()).is_equal(DrownedBrain.Target.PLAYER)


func test_hiding_during_sabotage_does_not_escalate() -> void:
	var brain := _brain(3.0)
	var senses := _senses(1.0, true)
	brain.start(senses, _rng())
	senses.player_in_reach = true
	brain.update(0.1, senses, _rng())
	# Ameaça sobe durante a perseguição, mas o jogador se esconde.
	senses.threat = 10.0
	senses.player_in_reach = false
	brain.update(0.1, senses, _rng())
	assert_int(brain.state).is_equal(DrownedBrain.State.GO_SABOTAGE)


func test_save_round_trip() -> void:
	var brain := _brain()
	var senses := _senses(3.0, true)
	brain.start(senses, _rng())
	senses.arrived = true
	brain.update(0.1, senses, _rng())
	brain.update(1.0, senses, _rng())
	var restored := _brain()
	restored.from_dict(brain.to_dict())
	assert_int(restored.state).is_equal(DrownedBrain.State.BANG_TRAPDOOR)
	restored.update(4.0, senses, _rng())
	assert_int(restored.state).is_equal(DrownedBrain.State.LEAVE)
