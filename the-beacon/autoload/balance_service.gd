extends Node
## Autoload BalanceService: as tabelas de balanceamento por noite (decisão 0031). Lê a tabela de
## cada dificuldade em `config/balance/<id>.json` e a guarda enquanto o jogo estiver aberto, para
## que as edições do painel de debug sobrevivam à recarga da cena a cada noite. O painel grava a
## tabela com `save`.

const PROJECT_DIR := "res://config/balance"

## Pasta das tabelas do projeto; os testes trocam por uma pasta temporária.
var project_dir: String = PROJECT_DIR

var _tables: Dictionary[StringName, BalanceTable] = {}
## Dificuldades com edições ainda não gravadas.
var _unsaved: Dictionary[StringName, bool] = {}


## Devolve a tabela da dificuldade, lida do arquivo na primeira chamada. Sem arquivo, a tabela
## repete em todas as noites os valores do `.tres`.
func table_for(difficulty: DifficultyConfig) -> BalanceTable:
	if _tables.has(difficulty.id):
		return _tables[difficulty.id]
	var table := BalanceTable.from_difficulty(difficulty)
	var path: String = project_path(difficulty.id)
	if FileAccess.file_exists(path):
		for warning: String in table.load_values(_read_json(path)):
			push_warning("%s: %s" % [path, warning])
	else:
		push_warning("Sem tabela de balanceamento em %s; usando os valores do .tres." % path)
	_tables[difficulty.id] = table
	return table


## Devolve uma cópia da dificuldade com os valores da noite (a primeira é 1). A dificuldade dada
## não muda.
func config_for_night(difficulty: DifficultyConfig, night: int) -> DifficultyConfig:
	return table_for(difficulty).config_for_night(difficulty, night)


## Marca a tabela da dificuldade como alterada desde a última leitura ou gravação.
func mark_changed(difficulty_id: StringName) -> void:
	_unsaved[difficulty_id] = true


## Diz se a tabela da dificuldade tem edições que ainda não foram gravadas.
func has_unsaved_changes(difficulty_id: StringName) -> bool:
	return _unsaved.get(difficulty_id, false)


## Grava a tabela da dificuldade em `save_path` e limpa a marca de alterada. Devolve o erro da
## gravação, ou `ERR_DOES_NOT_EXIST` se a tabela ainda não foi lida.
func save(difficulty_id: StringName) -> Error:
	var table: BalanceTable = _tables.get(difficulty_id)
	if table == null:
		return ERR_DOES_NOT_EXIST
	var path: String = save_path(difficulty_id)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(table.to_json_text())
	file.close()
	_unsaved.erase(difficulty_id)
	return OK


## Esquece a tabela da dificuldade e as edições dela: a próxima `table_for` lê o arquivo de novo.
func discard(difficulty_id: StringName) -> void:
	_tables.erase(difficulty_id)
	_unsaved.erase(difficulty_id)


## Devolve onde `save` grava a tabela da dificuldade.
func save_path(difficulty_id: StringName) -> String:
	return project_path(difficulty_id)


## Devolve o caminho da tabela da dificuldade no projeto.
func project_path(difficulty_id: StringName) -> String:
	return project_dir.path_join("%s.json" % difficulty_id)


## Devolve o conteúdo do arquivo JSON, ou vazio se não puder ler.
func _read_json(path: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	push_warning("Tabela de balanceamento ilegível: %s" % path)
	return {}
