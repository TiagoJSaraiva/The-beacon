extends GdUnitTestSuite

const CATALOG := "res://config/difficulties/catalog.tres"


func _catalog() -> DifficultyCatalog:
	return load(CATALOG)


func test_only_first_difficulty_starts_unlocked() -> void:
	var progress := ProgressState.new()
	var catalog: DifficultyCatalog = _catalog()
	assert_bool(progress.is_unlocked(&"easy", catalog)).is_true()
	assert_bool(progress.is_unlocked(&"medium", catalog)).is_false()
	assert_bool(progress.is_unlocked(&"hard", catalog)).is_false()


func test_victory_unlocks_only_the_next_difficulty() -> void:
	var progress := ProgressState.new()
	var catalog: DifficultyCatalog = _catalog()
	assert_str(progress.register_victory(&"easy", catalog)).is_equal("medium")
	assert_bool(progress.is_unlocked(&"medium", catalog)).is_true()
	assert_bool(progress.is_unlocked(&"hard", catalog)).is_false()
	assert_str(progress.register_victory(&"medium", catalog)).is_equal("hard")
	assert_bool(progress.is_unlocked(&"hard", catalog)).is_true()


func test_repeated_or_last_victory_unlocks_nothing_new() -> void:
	var progress := ProgressState.new()
	var catalog: DifficultyCatalog = _catalog()
	progress.register_victory(&"easy", catalog)
	assert_str(progress.register_victory(&"easy", catalog)).is_empty()
	assert_str(progress.register_victory(&"hard", catalog)).is_empty()
	assert_int(progress.unlocked_ids.size()).is_equal(1)


func test_save_round_trip_through_json() -> void:
	var progress := ProgressState.new()
	var catalog: DifficultyCatalog = _catalog()
	progress.register_victory(&"easy", catalog)
	var restored := ProgressState.new()
	restored.from_dict(JSON.parse_string(JSON.stringify(progress.to_dict())))
	assert_bool(restored.is_unlocked(&"medium", catalog)).is_true()
	assert_bool(restored.is_unlocked(&"hard", catalog)).is_false()
