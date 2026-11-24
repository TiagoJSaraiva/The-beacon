extends GdUnitTestSuite
## Campos editáveis e seções dos valores de balanceamento, de onde sai a tabela por noite.


func test_fields_list_numbers_and_bools_with_range_and_group() -> void:
	var fields: Array[ConfigFields.Field] = ConfigFields.fields(FogConfig.new())
	var by_name: Dictionary[StringName, ConfigFields.Field] = {}
	for field: ConfigFields.Field in fields:
		by_name[field.name] = field

	var near: ConfigFields.Field = by_name[&"near_advance"]
	assert_int(near.type).is_equal(TYPE_FLOAT)
	assert_bool(near.has_range).is_true()
	assert_float(near.max_value).is_equal(1.0)
	assert_float(near.step).is_equal(0.01)
	assert_str(near.group).is_equal("Estágios")
	var grace: ConfigFields.Field = by_name[&"idle_grace_seconds"]
	assert_bool(grace.has_range).is_false()
	assert_str(grace.group).is_equal("Farol parado")


func test_fields_skip_text_and_hidden_names() -> void:
	var names: Array[StringName] = []
	for field: ConfigFields.Field in ConfigFields.fields(DifficultyConfig.new(), [&"nights"]):
		names.append(field.name)

	assert_array(names).contains([&"tutorial_enabled", &"event_chance_multiplier"])
	assert_array(names).not_contains([&"id", &"display_name", &"nights", &"events"])


func test_sections_cover_sub_configs_and_events() -> void:
	var difficulty: DifficultyConfig = load("res://config/difficulties/easy.tres")
	var labels: Array[String] = []
	for section: ConfigFields.Section in ConfigFields.sections(difficulty):
		labels.append(section.label)

	assert_str(labels[0]).is_equal("difficulty")
	assert_array(labels).contains(["fog", "power", "drowned", "events/boat"])
