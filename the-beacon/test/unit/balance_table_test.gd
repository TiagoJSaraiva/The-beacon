extends GdUnitTestSuite
## Tabela de balanceamento por noite: linhas tiradas da dificuldade, valores por noite, aplicação
## numa cópia e ida e volta pelo JSON.


func _difficulty() -> DifficultyConfig:
	var difficulty: DifficultyConfig = load("res://config/difficulties/easy.tres").duplicate_deep(
		Resource.DEEP_DUPLICATE_ALL
	)
	difficulty.nights = 3
	return difficulty


func test_rows_come_from_numeric_fields_without_run_fields() -> void:
	var table := BalanceTable.from_difficulty(_difficulty())

	assert_int(table.nights).is_equal(3)
	assert_object(table.row("fog.advance_per_second")).is_not_null()
	assert_object(table.row("events/boat.chance_per_check")).is_not_null()
	assert_object(table.row("difficulty.event_chance_multiplier")).is_not_null()
	assert_object(table.row("difficulty.nights")).is_null()
	assert_object(table.row("difficulty.tutorial_enabled")).is_null()
	assert_object(table.row("events/boat.id")).is_null()


func test_rows_follow_theme_order() -> void:
	var table := BalanceTable.from_difficulty(_difficulty())
	var themes: Array[String] = []
	for row: BalanceTable.Row in table.rows:
		if themes.is_empty() or themes[-1] != row.theme:
			themes.append(row.theme)

	assert_array(themes).is_equal(
		["Noite", "Quebras", "Energia", "Nevoeiro", "Barcos", "Afogado", "Carranca", "Jogador"]
	)
	assert_str(BalanceTable.theme_of("algo_novo")).is_equal(BalanceTable.OTHER_THEME)


func test_values_start_equal_and_keep_field_type() -> void:
	var difficulty := _difficulty()
	var table := BalanceTable.from_difficulty(difficulty)

	for night: int in [1, 2, 3]:
		assert_float(table.value("boat.crossing_seconds", night)).is_equal(
			difficulty.boat.crossing_seconds
		)
	assert_bool(table.value("events/boat.max_per_night", 2) is int).is_true()


func test_set_fill_and_differs_from_previous() -> void:
	var table := BalanceTable.from_difficulty(_difficulty())
	table.set_value("boat.crossing_seconds", 2, 30.0)

	assert_bool(table.differs_from_previous("boat.crossing_seconds", 1)).is_false()
	assert_bool(table.differs_from_previous("boat.crossing_seconds", 2)).is_true()
	assert_bool(table.differs_from_previous("boat.crossing_seconds", 3)).is_true()

	table.fill_following("boat.crossing_seconds", 2)
	assert_float(table.value("boat.crossing_seconds", 3)).is_equal(30.0)
	assert_bool(table.differs_from_previous("boat.crossing_seconds", 3)).is_false()


func test_config_for_night_changes_only_the_copy() -> void:
	var base := _difficulty()
	var boat_event: EventDefinition = base.events[3]
	var original_chance: float = boat_event.chance_per_check
	var table := BalanceTable.from_difficulty(base)
	table.set_value("boat.crossing_seconds", 2, 33.0)
	table.set_value("events/boat.chance_per_check", 2, 0.9)

	var night_two: DifficultyConfig = table.config_for_night(base, 2)

	assert_float(night_two.boat.crossing_seconds).is_equal(33.0)
	assert_float(night_two.events[3].chance_per_check).is_equal_approx(0.9, 0.0001)
	assert_float(base.boat.crossing_seconds).is_not_equal(33.0)
	assert_float(boat_event.chance_per_check).is_equal(original_chance)
	assert_float(table.config_for_night(base, 1).boat.crossing_seconds).is_equal(
		base.boat.crossing_seconds
	)


func test_json_round_trip_keeps_values_and_types() -> void:
	var table := BalanceTable.from_difficulty(_difficulty())
	table.set_value("fog.advance_per_second", 3, 0.0125)
	table.set_value("events/boat.max_per_night", 2, 7)
	var text: String = table.to_json_text()

	assert_str(text).contains('"events/boat.max_per_night": [4, 7, 4]')
	var loaded := BalanceTable.from_difficulty(_difficulty())
	var warnings: PackedStringArray = loaded.load_values(JSON.parse_string(text))

	assert_int(warnings.size()).is_equal(0)
	assert_float(loaded.value("fog.advance_per_second", 3)).is_equal_approx(0.0125, 0.000001)
	assert_int(loaded.value("events/boat.max_per_night", 2)).is_equal(7)


func test_load_values_pads_cuts_and_warns() -> void:
	var table := BalanceTable.from_difficulty(_difficulty())
	var data: Dictionary = {
		"rows":
		{
			"boat.crossing_seconds": [10.0, 11.0],
			"fall.fatal_height": [5.0, 6.0, 7.0, 8.0],
			"nao.existe": [1.0],
		}
	}

	var warnings: PackedStringArray = table.load_values(data)

	assert_int(warnings.size()).is_equal(1)
	assert_float(table.value("boat.crossing_seconds", 3)).is_equal(11.0)
	assert_float(table.value("fall.fatal_height", 3)).is_equal(7.0)
	assert_int(table.row("fall.fatal_height").values.size()).is_equal(3)
