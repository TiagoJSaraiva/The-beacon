extends SceneTree
## Extrai um modelo baixado (zip) para res://assets/models/<nome>/, reduzindo as texturas e
## descartando os mapas sem uso (regras em tools/model_import_rules.gd). Rodar da raiz do projeto:
##   godot --headless --path . --script res://tools/import_store_model.gd -- <zip> <nome>
##       [--inner <zip dentro do zip>] [--max-size 2048] [--skip <marcador>]...
## O Godot importa os arquivos novos no próximo --import (o check faz isso). Os originais
## ficam fora do repositório, em notes/modelos-store/.

const Rules := preload("res://tools/model_import_rules.gd")

const OUTPUT_ROOT := "res://assets/models/"
const DEFAULT_MAX_SIZE := 2048
const JPG_QUALITY := 0.9


## Lê os argumentos, extrai o pacote e encerra com código 0 em sucesso ou 1 em erro.
func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Uso: -- <zip> <nome> [--inner <entrada>] [--max-size N] [--skip <marcador>]")
		quit(1)
		return
	var zip_path: String = args[0]
	var model_name: String = args[1]
	var inner: String = ""
	var max_size: int = DEFAULT_MAX_SIZE
	var skips := PackedStringArray()
	var i: int = 2
	while i < args.size():
		if i + 1 >= args.size():
			push_error("Falta o valor de %s" % args[i])
			quit(1)
			return
		match args[i]:
			"--inner":
				inner = args[i + 1]
			"--max-size":
				max_size = args[i + 1].to_int()
			"--skip":
				skips.append(args[i + 1])
			_:
				push_error("Argumento desconhecido: %s" % args[i])
				quit(1)
				return
		i += 2
	if not inner.is_empty():
		zip_path = _extract_inner_zip(zip_path, inner)
		if zip_path.is_empty():
			quit(1)
			return
	var ok: bool = _extract(zip_path, OUTPUT_ROOT + model_name + "/", max_size, skips)
	quit(0 if ok else 1)


## Copia a entrada `inner` do zip `zip_path` para um arquivo temporário e devolve o caminho
## dele, ou `""` (com erro no console) se não conseguir.
func _extract_inner_zip(zip_path: String, inner: String) -> String:
	var reader := ZIPReader.new()
	if reader.open(zip_path) != OK:
		push_error("Não abriu o zip: %s" % zip_path)
		return ""
	var bytes: PackedByteArray = reader.read_file(inner)
	reader.close()
	if bytes.is_empty():
		push_error("Entrada não encontrada no zip: %s" % inner)
		return ""
	var temp_path: String = OS.get_cache_dir().path_join("beacon_inner_model.zip")
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("Não gravou o zip temporário: %s" % temp_path)
		return ""
	file.store_buffer(bytes)
	file.close()
	return temp_path


## Extrai do zip as entradas aproveitadas para `output_dir`, sem a pasta de topo comum, e
## reduz as texturas maiores que `max_size`. Devolve se tudo foi gravado.
func _extract(
	zip_path: String, output_dir: String, max_size: int, skips: PackedStringArray
) -> bool:
	var reader := ZIPReader.new()
	if reader.open(zip_path) != OK:
		push_error("Não abriu o zip: %s" % zip_path)
		return false
	var entries: PackedStringArray = reader.get_files()
	var top_folder: String = Rules.common_root(entries)
	var ok: bool = true
	for entry in entries:
		if not Rules.is_wanted(entry, skips):
			continue
		var target: String = output_dir + entry.trim_prefix(top_folder)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target.get_base_dir()))
		var bytes: PackedByteArray = reader.read_file(entry)
		if Rules.is_texture(entry):
			ok = _save_texture(bytes, target, max_size) and ok
		else:
			ok = _save_bytes(bytes, target) and ok
	reader.close()
	return ok


## Grava a textura em `target`, no formato original. Se o maior lado passar de `max_size`,
## reduz antes; senão, copia os bytes sem recomprimir. Devolve se gravou.
func _save_texture(bytes: PackedByteArray, target: String, max_size: int) -> bool:
	var image := Image.new()
	var is_png: bool = target.get_extension().to_lower() == "png"
	var error: Error = (
		image.load_png_from_buffer(bytes) if is_png else image.load_jpg_from_buffer(bytes)
	)
	if error != OK:
		push_error("Não leu a textura: %s" % target)
		return false
	var size: Vector2i = image.get_size()
	var fitted: Vector2i = Rules.fitted_size(size, max_size)
	if fitted == size:
		return _save_bytes(bytes, target)
	image.resize(fitted.x, fitted.y, Image.INTERPOLATE_LANCZOS)
	var path: String = ProjectSettings.globalize_path(target)
	error = image.save_png(path) if is_png else image.save_jpg(path, JPG_QUALITY)
	print("%s: %dx%d -> %dx%d" % [target, size.x, size.y, fitted.x, fitted.y])
	return error == OK


## Grava os bytes em `target` como estão e devolve se conseguiu.
func _save_bytes(bytes: PackedByteArray, target: String) -> bool:
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		push_error("Não gravou: %s" % target)
		return false
	file.store_buffer(bytes)
	file.close()
	print(target)
	return true
