extends GdUnitTestSuite
## Horário do relógio de parede: segue o jogo fora da vista, corre em tempo real enquanto é visto.


func test_text_round_trip_crosses_midnight() -> void:
	assert_int(ClockDisplayRules.to_minutes("20:00")).is_equal(480)
	assert_int(ClockDisplayRules.to_minutes("00:30")).is_equal(750)
	assert_int(ClockDisplayRules.to_minutes("06:00")).is_equal(1080)
	assert_str(ClockDisplayRules.to_text(480)).is_equal("20:00")
	assert_str(ClockDisplayRules.to_text(750)).is_equal("00:30")
	assert_str(ClockDisplayRules.to_text(1080)).is_equal("06:00")


func test_follows_the_game_when_not_looked_at() -> void:
	var rules := ClockDisplayRules.new(60.0)
	rules.set_game_time("21:15")
	assert_str(rules.advance(0.1, false)).is_equal("21:15")
	rules.set_game_time("21:16")
	assert_str(rules.advance(0.1, false)).is_equal("21:16")


func test_looking_freezes_and_runs_in_real_time() -> void:
	var rules := ClockDisplayRules.new(60.0)
	rules.set_game_time("21:00")
	rules.advance(0.1, false)
	# O jogo corre 40 vezes mais depressa que o visor visto.
	for second: int in 59:
		rules.set_game_time(
			ClockDisplayRules.to_text(ClockDisplayRules.to_minutes("21:00") + second)
		)
		assert_str(rules.advance(1.0, true)).is_equal("21:00")
	rules.set_game_time("22:30")
	assert_str(rules.advance(1.0, true)).is_equal("21:01")
	assert_str(rules.advance(60.0, true)).is_equal("21:02")


func test_looking_away_snaps_to_the_game_time_and_looking_again_refreezes() -> void:
	var rules := ClockDisplayRules.new(60.0)
	rules.set_game_time("22:00")
	assert_str(rules.advance(0.1, false)).is_equal("22:00")
	assert_str(rules.advance(5.0, true)).is_equal("22:00")
	rules.set_game_time("22:10")
	assert_str(rules.advance(5.0, true)).is_equal("22:00")
	assert_str(rules.advance(0.1, false)).is_equal("22:10")
	assert_str(rules.advance(5.0, true)).is_equal("22:10")


func test_never_passes_the_game_time() -> void:
	var rules := ClockDisplayRules.new(1.0)
	rules.set_game_time("23:00")
	rules.advance(0.1, false)
	assert_str(rules.advance(500.0, true)).is_equal("23:00")


func test_keeps_running_past_midnight() -> void:
	var rules := ClockDisplayRules.new(60.0)
	rules.set_game_time("23:59")
	rules.advance(0.1, false)
	rules.advance(0.1, true)
	rules.set_game_time("01:00")
	assert_str(rules.advance(60.0, true)).is_equal("00:00")
	assert_str(rules.advance(60.0, true)).is_equal("00:01")
