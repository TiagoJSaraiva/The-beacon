extends Node
## Autoload SaveService: o save único da partida e o progresso de desbloqueio, em arquivos
## separados para que apagar um nunca toque no outro (GDD 1.2.14; decisão 0014).

const RUN_SAVE_PATH := "user://run_save.json"
const PROGRESS_PATH := "user://progress.json"
## Sobe quando o formato muda; um save de outra versão é ignorado.
const SAVE_VERSION := 3

var progress: ProgressState = ProgressState.new()


## Carrega o progresso de desbloqueio ao abrir o jogo.
func _ready() -> void:
	progress.from_dict(_read_json(PROGRESS_PATH))


## Diz se existe uma partida válida para continuar.
func has_run_save() -> bool:
	return not read_run().is_empty()


## Devolve a partida salva; vazio se não existe, está corrompida ou é de outra versão.
func read_run() -> Dictionary:
	var data: Dictionary = _read_json(RUN_SAVE_PATH)
	if data.get("version", -1) != SAVE_VERSION:
		return {}
	return data.get("run", {})


## Grava a partida no arquivo de save, com a versão atual do formato.
func write_run(run: Dictionary) -> void:
	_write_json(RUN_SAVE_PATH, {"version": SAVE_VERSION, "run": run})


## Apaga o save da partida, se existir. O progresso de desbloqueio não muda.
func delete_run() -> void:
	if FileAccess.file_exists(RUN_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_SAVE_PATH))


## Diz se a dificuldade está liberada para jogar.
func is_unlocked(difficulty_id: StringName, catalog: DifficultyCatalog) -> bool:
	return progress.is_unlocked(difficulty_id, catalog)


## Registra a vitória e grava o progresso só se ela liberou algo novo.
func register_victory(difficulty_id: StringName, catalog: DifficultyCatalog) -> void:
	if progress.register_victory(difficulty_id, catalog) != &"":
		_write_json(PROGRESS_PATH, progress.to_dict())


## Devolve o conteúdo do arquivo JSON. Se ele não existe ou está ilegível, devolve vazio.
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed
	push_warning("Arquivo de save ilegível: %s" % path)
	return {}


## Grava o dicionário como JSON. Em caso de falha, registra o erro.
func _write_json(path: String, data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível gravar %s: %s" % [path, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data, "\t"))
