extends GdUnitTestSuite
## Tabelas por noite pelo BalanceService: arquivo do projeto, falta de arquivo, cache entre
## recargas, gravação, descarte e cópia local do executável exportado.

const SERVICE_SCRIPT := "res://autoload/balance_service.gd"
const TEST_DIR := "user://balance_service_test"
const LOCAL_TEST_DIR := "user://balance_service_test_local"

var _service: Node


func before_test() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	_service = auto_free(load(SERVICE_SCRIPT).new())
	_service.project_dir = TEST_DIR
	_service.local_dir = LOCAL_TEST_DIR
	_service.local_copy_enabled = false


func after_test() -> void:
	for directory: String in [TEST_DIR, LOCAL_TEST_DIR]:
		for file_name: String in DirAccess.get_files_at(directory):
			DirAccess.remove_absolute(directory.path_join(file_name))
		DirAccess.remove_absolute(directory)


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


func test_save_writes_the_table_and_discard_reads_it_again() -> void:
	var table: BalanceTable = _service.table_for(_easy())
	table.set_value("boat.crossing_seconds", 2, 55.0)
	_service.mark_changed(&"easy")

	assert_int(_service.save(&"easy")).is_equal(OK)
	assert_bool(_service.has_unsaved_changes(&"easy")).is_false()
	table.set_value("boat.crossing_seconds", 2, 66.0)
	_service.discard(&"easy")

	assert_float(_service.config_for_night(_easy(), 2).boat.crossing_seconds).is_equal(55.0)
	assert_int(_service.save(&"medium")).is_equal(ERR_DOES_NOT_EXIST)


func test_local_copy_is_saved_and_read_only_when_enabled() -> void:
	_write("easy.json", '{"rows": {"boat.crossing_seconds": [11.0, 11.0, 11.0]}}')
	_service.local_copy_enabled = true
	_service.table_for(_easy()).set_value("boat.crossing_seconds", 1, 77.0)

	assert_int(_service.save(&"easy")).is_equal(OK)
	assert_bool(FileAccess.file_exists(LOCAL_TEST_DIR.path_join("easy.json"))).is_true()
	assert_str(FileAccess.get_file_as_string(TEST_DIR.path_join("easy.json"))).contains("11.0")
	_service.discard(&"easy")
	assert_bool(_service.is_using_local_copy(&"easy")).is_true()
	assert_float(_service.config_for_night(_easy(), 1).boat.crossing_seconds).is_equal(77.0)

	# Rodando pelo editor, a cópia local não vale.
	_service.local_copy_enabled = false
	_service.discard(&"easy")
	assert_float(_service.config_for_night(_easy(), 1).boat.crossing_seconds).is_equal(11.0)

	_service.local_copy_enabled = true
	_service.delete_local_copy(&"easy")
	assert_bool(_service.is_using_local_copy(&"easy")).is_false()
	assert_float(_service.config_for_night(_easy(), 1).boat.crossing_seconds).is_equal(11.0)


func test_project_tables_match_the_catalog() -> void:
	var catalog: DifficultyCatalog = load("res://config/difficulties/catalog.tres")
	for difficulty: DifficultyConfig in catalog.difficulties:
		var path: String = BalanceService.project_path(difficulty.id)
		assert_bool(FileAccess.file_exists(path)).override_failure_message(path).is_true()
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		assert_int(int(data["nights"])).is_equal(difficulty.nights)
		var table := BalanceTable.from_difficulty(difficulty)
		assert_int(table.load_values(data).size()).override_failure_message(path).is_equal(0)
