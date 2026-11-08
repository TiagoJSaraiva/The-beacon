class_name ModelImportRules
extends RefCounted
## Regras puras da importação de modelos de terceiros: o que extrair do pacote e em que tamanho.

## Extensões de arquivo que a importação aproveita: modelo e texturas.
const MODEL_EXTENSIONS: PackedStringArray = ["gltf", "glb", "bin", "fbx"]
const TEXTURE_EXTENSIONS: PackedStringArray = ["png", "jpg", "jpeg"]

## Marcadores de mapas que o StandardMaterial3D não usa; descartados para não pesar no repositório.
const UNUSED_MAP_MARKERS: PackedStringArray = [
	"_cavity", "_displacement", "_gloss", "_specular", "_height"
]

## Valores das opções do importador de texturas do Godot (`compress/mode`,
## `detect_3d/compress_to`, `compress/normal_map`).
const COMPRESS_VRAM := 2
const DETECT_3D_DISABLED := 0
const NORMAL_MAP_ENABLED := 1


## Devolve `size` reduzido para que o maior lado caiba em `max_side`, mantendo a proporção
## e com no mínimo 1 px por lado. Um tamanho que já cabe volta igual: a regra nunca amplia.
static func fitted_size(size: Vector2i, max_side: int) -> Vector2i:
	var longest: int = maxi(size.x, size.y)
	if longest <= max_side:
		return size
	var ratio: float = float(max_side) / longest
	return Vector2i(maxi(roundi(size.x * ratio), 1), maxi(roundi(size.y * ratio), 1))


## Diz se a entrada do pacote deve ser extraída: só arquivos de modelo ou textura, e
## nenhuma textura cujo nome traga um dos marcadores de `UNUSED_MAP_MARKERS` ou de `extra_skips`
## (sem distinguir maiúsculas). Pastas (terminadas em `/`) ficam de fora.
static func is_wanted(entry: String, extra_skips: PackedStringArray = []) -> bool:
	if entry.ends_with("/"):
		return false
	var extension: String = entry.get_extension().to_lower()
	if extension in MODEL_EXTENSIONS:
		return true
	if not extension in TEXTURE_EXTENSIONS:
		return false
	var file_name: String = entry.get_file().to_lower()
	for marker in UNUSED_MAP_MARKERS + extra_skips:
		if file_name.contains(marker.to_lower()):
			return false
	return true


## Diz se a entrada é uma textura, que passa pela redução de tamanho.
static func is_texture(entry: String) -> bool:
	return entry.get_extension().to_lower() in TEXTURE_EXTENSIONS


## Diz se a textura é um mapa de normal, pelo nome (ex.: `chair_normal.png`).
static func is_normal_map(file_name: String) -> bool:
	return file_name.get_file().to_lower().contains("normal")


## Devolve as opções de import (seção `[params]` do `.import`) de uma textura de modelo:
## compressão de VRAM com mipmaps, sem a detecção de uso em 3D, que só mudaria o arquivo
## ao abrir o editor; nos mapas de normal, também o modo de normal map.
static func texture_import_params(file_name: String) -> Dictionary:
	var params: Dictionary = {
		"compress/mode": COMPRESS_VRAM,
		"mipmaps/generate": true,
		"detect_3d/compress_to": DETECT_3D_DISABLED,
	}
	if is_normal_map(file_name):
		params["compress/normal_map"] = NORMAL_MAP_ENABLED
	return params


## Devolve a pasta de topo comum a todas as entradas (ex.: `"Generator/"`), ou `""` se não
## houver uma. A extração a remove para o modelo ficar na raiz da pasta de destino.
static func common_root(entries: PackedStringArray) -> String:
	if entries.is_empty():
		return ""
	var first: String = entries[0]
	var slash: int = first.find("/")
	if slash < 0:
		return ""
	var root: String = first.substr(0, slash + 1)
	for entry in entries:
		if not entry.begins_with(root):
			return ""
	return root
