extends GdUnitTestSuite

const CATALOG_PATH := "res://config/difficulties/catalog.tres"


func test_catalog_lists_difficulties_in_unlock_order() -> void:
	var catalog: DifficultyCatalog = load(CATALOG_PATH)
	var ids: Array[StringName] = []
	for difficulty: DifficultyConfig in catalog.difficulties:
		ids.append(difficulty.id)
	assert_array(ids).is_equal([&"easy", &"medium", &"hard"])


func test_nights_per_difficulty_match_gdd() -> void:
	var catalog: DifficultyCatalog = load(CATALOG_PATH)
	assert_int(catalog.find_by_id(&"easy").nights).is_equal(3)
	assert_int(catalog.find_by_id(&"medium").nights).is_equal(5)
	assert_int(catalog.find_by_id(&"hard").nights).is_equal(7)


func test_only_easy_has_tutorial() -> void:
	var catalog: DifficultyCatalog = load(CATALOG_PATH)
	assert_bool(catalog.find_by_id(&"easy").tutorial_enabled).is_true()
	assert_bool(catalog.find_by_id(&"medium").tutorial_enabled).is_false()
	assert_bool(catalog.find_by_id(&"hard").tutorial_enabled).is_false()


func test_every_difficulty_is_valid() -> void:
	var catalog: DifficultyCatalog = load(CATALOG_PATH)
	for difficulty: DifficultyConfig in catalog.difficulties:
		var errors := Array(difficulty.validate())
		assert_array(errors).override_failure_message("%s: %s" % [difficulty.id, errors]).is_empty()


func test_validate_reports_missing_sub_config() -> void:
	var difficulty := DifficultyConfig.new()
	difficulty.id = &"broken"
	assert_array(Array(difficulty.validate())).contains(["time não atribuído"])


func test_chance_multiplier_grows_each_night() -> void:
	var difficulty := DifficultyConfig.new()
	difficulty.event_chance_multiplier = 2.0
	difficulty.chance_increase_per_night = 0.5
	assert_float(difficulty.chance_multiplier_for_night(1)).is_equal_approx(2.0, 0.0001)
	assert_float(difficulty.chance_multiplier_for_night(3)).is_equal_approx(4.0, 0.0001)


func test_find_by_id_returns_null_for_unknown() -> void:
	var catalog: DifficultyCatalog = load(CATALOG_PATH)
	assert_object(catalog.find_by_id(&"nightmare")).is_null()
