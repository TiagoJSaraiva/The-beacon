extends GdUnitTestSuite


func test_defaults_match_the_project_input_map() -> void:
	var bindings := InputBindings.new()
	assert_int(bindings.keys[&"interact"]).is_equal(KEY_E)
	assert_int(bindings.keys[&"pause"]).is_equal(KEY_ESCAPE)
	assert_int(bindings.buttons[&"jump"]).is_equal(JOY_BUTTON_A)
	assert_bool(bindings.buttons.has(&"sprint")).is_false()


func test_binding_a_used_key_swaps_the_two_actions() -> void:
	var bindings := InputBindings.new()
	bindings.bind_key(&"interact", KEY_Q)
	assert_int(bindings.keys[&"interact"]).is_equal(KEY_Q)
	assert_int(bindings.keys[&"toggle_flashlight"]).is_equal(KEY_E)


func test_binding_a_used_button_swaps_the_two_actions() -> void:
	var bindings := InputBindings.new()
	bindings.bind_button(&"jump", JOY_BUTTON_B)
	assert_int(bindings.buttons[&"jump"]).is_equal(JOY_BUTTON_B)
	assert_int(bindings.buttons[&"drop_item"]).is_equal(JOY_BUTTON_A)


func test_fixed_joypad_actions_cannot_be_rebound() -> void:
	var bindings := InputBindings.new()
	bindings.bind_button(&"sprint", JOY_BUTTON_A)
	assert_bool(bindings.buttons.has(&"sprint")).is_false()
	assert_int(bindings.buttons[&"jump"]).is_equal(JOY_BUTTON_A)
	assert_str(bindings.label_for(&"sprint", true)).is_equal("L2")


func test_round_trip_through_dictionary() -> void:
	var bindings := InputBindings.new()
	bindings.bind_key(&"jump", KEY_C)
	bindings.bind_button(&"pause", JOY_BUTTON_BACK)
	var restored := InputBindings.new()
	restored.from_dict(bindings.to_dict())
	assert_int(restored.keys[&"jump"]).is_equal(KEY_C)
	assert_int(restored.buttons[&"pause"]).is_equal(JOY_BUTTON_BACK)


func test_invalid_or_repeated_file_values_fall_back_to_defaults() -> void:
	var repeated := InputBindings.new()
	repeated.from_dict({"keys": {"jump": KEY_E, "interact": KEY_E}})
	assert_int(repeated.keys[&"jump"]).is_equal(KEY_SPACE)
	assert_int(repeated.keys[&"interact"]).is_equal(KEY_E)
	var invalid := InputBindings.new()
	invalid.from_dict({"buttons": {"jump": -3}, "keys": "nada"})
	assert_int(invalid.buttons[&"jump"]).is_equal(JOY_BUTTON_A)
