extends SceneTree
## Ajusta as opções de import das texturas de um modelo de res://assets/models/<nome>/ para uso
## em 3D: compressão de VRAM, mipmaps e, nos mapas de normal, o modo de normal map (regras em
## tools/model_import_rules.gd). Rodar da raiz do projeto, depois de o Godot ter importado o
## modelo uma vez (o .import precisa existir):
##   godot --headless --path . --script res://tools/configure_model_textures.gd -- <nome>
## O próximo --import (o check faz isso) reimporta as texturas com as opções novas.

const Rules := preload("res://tools/model_import_rules.gd")

const MODELS_ROOT := "res://assets/models/"


## Lê o nome do modelo, ajusta o .import de cada textura da pasta e encerra com código 0 em
## sucesso ou 1 em erro.
func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Uso: -- <nome>")
		quit(1)
		return
	var folder: String = MODELS_ROOT + args[0] + "/"
	if not DirAccess.dir_exists_absolute(folder):
		push_error("Pasta não encontrada: %s" % folder)
		quit(1)
		return
	quit(0 if _configure_folder(folder) else 1)


## Ajusta o .import de toda textura da pasta e das subpastas. Devolve se todas tinham .import
## e foram gravadas.
func _configure_folder(folder: String) -> bool:
	var ok: bool = true
	for file_name in DirAccess.get_files_at(folder):
		if Rules.is_texture(file_name):
			ok = _configure_texture(folder + file_name) and ok
	for sub in DirAccess.get_directories_at(folder):
		ok = _configure_folder(folder + sub + "/") and ok
	return ok


## Grava em `<textura>.import` os parâmetros de `ModelImportRules.texture_import_params`.
## Devolve se o .import existia e foi gravado.
func _configure_texture(texture_path: String) -> bool:
	var import_path: String = texture_path + ".import"
	var config := ConfigFile.new()
	if config.load(import_path) != OK:
		push_error("Sem .import (rode o --import antes): %s" % texture_path)
		return false
	var params: Dictionary = Rules.texture_import_params(texture_path.get_file())
	for key: String in params:
		config.set_value("params", key, params[key])
	if config.save(import_path) != OK:
		push_error("Não gravou: %s" % import_path)
		return false
	print(import_path)
	return true
