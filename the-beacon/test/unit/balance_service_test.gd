extends GdUnitTestSuite
## Leitura das tabelas por noite pelo BalanceService: arquivo do projeto, falta de arquivo e
## cache entre recargas.

const SERVICE_SCRIPT := "res://autoload/balance_service.gd"
const TEST_DIR := "user://balance_service_test"

var _service: Node


func before_test() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	_service = auto_free(load(SERVICE_SCRIPT).new())
	_service.project_dir = TEST_DIR


func after_test() -> void:
	for file_name: String in DirAccess.get_files_at(TEST_DIR):
		DirAccess.remove_absolute(TEST_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_DIR)


func _easy() -> DifficultyConfig:
	return load("res://config/difficulties/easy.tres")


func _write(file_name: String, text: String) -> void:
	var file := FileAccess.open(TEST_DIR.path_join(file_name), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_reads_the_night_values_from_the_file() -> void:
	_write("easy.json", '{"rows": {"boat.crossing_seconds": [11.0, 22.0, 33.0]}}')

	var night_two: DifficultyConfig = _service.config_for_night(_easy(), 2)

	assert_float(night_two.boat.crossing_seconds).is_equal(22.0)
	assert_float(_easy().boat.crossing_seconds).is_not_equal(22.0)


func test_without_file_uses_the_tres_values() -> void:
	var night_one: DifficultyConfig = _service.config_for_night(_easy(), 1)

	assert_float(night_one.boat.crossing_seconds).is_equal(_easy().boat.crossing_seconds)


func test_keeps_the_table_after_the_first_read() -> void:
	var table: BalanceTable = _service.table_for(_easy())
	table.set_value("boat.crossing_seconds", 3, 44.0)

	assert_object(_service.table_for(_easy())).is_same(table)
	assert_float(_service.config_for_night(_easy(), 3).boat.crossing_seconds).is_equal(44.0)


func test_project_tables_match_the_catalog() -> void:
	var catalog: DifficultyCatalog = load("res://config/difficulties/catalog.tres")
	for difficulty: DifficultyConfig in catalog.difficulties:
		var path: String = BalanceService.project_path(difficulty.id)
		assert_bool(FileAccess.file_exists(path)).override_failure_message(path).is_true()
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		assert_int(int(data["nights"])).is_equal(difficulty.nights)
		var table := BalanceTable.from_difficulty(difficulty)
		assert_int(table.load_values(data).size()).override_failure_message(path).is_equal(0)
