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
