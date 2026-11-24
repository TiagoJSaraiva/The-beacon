class_name ConfigFields
extends RefCounted
## Lê, compara e copia os valores de balanceamento (`@export` de número ou bool) de um
## `Resource` de configuração, para o editor do painel de debug (decisão 0024).


## Um campo editável: nome, tipo e, se o `@export_range` der, a faixa.
class Field:
	extends RefCounted
	var name: StringName
	var type: Variant.Type
	## Grupo do `@export_group` em que o campo está; vazio fora de grupo.
	var group: String = ""
	var has_range: bool = false
	var min_value: float = 0.0
	var max_value: float = 0.0
	var step: float = 0.0


## Uma parte da dificuldade com nome para mostrar: a própria dificuldade, um sub-config ou um
## evento.
class Section:
	extends RefCounted
	var label: String
	var resource: Resource

	## Cria a seção com o nome e o recurso dados.
	func _init(section_label: String, section_resource: Resource) -> void:
		label = section_label
		resource = section_resource


## Devolve os campos float, int e bool exportados pelo script do recurso, na ordem do script,
## sem os nomes de `hidden`.
static func fields(resource: Resource, hidden: Array[StringName] = []) -> Array[Field]:
	var result: Array[Field] = []
	var group: String = ""
	for property: Dictionary in resource.get_property_list():
		var usage: int = property["usage"]
		if usage & PROPERTY_USAGE_GROUP:
			group = property["name"]
			continue
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE and usage & PROPERTY_USAGE_EDITOR):
			continue
		var type: int = property["type"]
		if type not in [TYPE_FLOAT, TYPE_INT, TYPE_BOOL]:
			continue
		var field_name := StringName(property["name"])
		if field_name in hidden:
			continue
		var field := Field.new()
		field.name = field_name
		field.type = type as Variant.Type
		field.group = group
		if property["hint"] == PROPERTY_HINT_RANGE:
			_read_range(field, property["hint_string"])
		result.append(field)
	return result


## Devolve as seções da dificuldade: ela mesma ("difficulty"), cada sub-config pelo nome da
## propriedade ("fog", "power"...) e cada evento como "events/<id>".
static func sections(difficulty: DifficultyConfig) -> Array[Section]:
	var result: Array[Section] = [Section.new("difficulty", difficulty)]
	for property: Dictionary in difficulty.get_property_list():
		var usage: int = property["usage"]
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) or property["type"] != TYPE_OBJECT:
			continue
		var sub_config := difficulty.get(property["name"]) as Resource
		if sub_config != null:
			result.append(Section.new(property["name"], sub_config))
	for definition: EventDefinition in difficulty.events:
		result.append(Section.new("events/%s" % definition.id, definition))
	return result


## Devolve uma linha "<campo>: <original> -> <atual>" para cada campo que difere entre os dois
## recursos (do mesmo script).
static func differences(current: Resource, original: Resource) -> PackedStringArray:
	var lines := PackedStringArray()
	for field: Field in fields(current):
		var now: Variant = current.get(field.name)
		var before: Variant = original.get(field.name)
		if now != before:
			lines.append("%s: %s -> %s" % [field.name, before, now])
	return lines


## Copia para `target` os valores de todos os campos de `source` (do mesmo script).
static func copy_values(source: Resource, target: Resource) -> void:
	for field: Field in fields(source):
		target.set(field.name, source.get(field.name))


## Lê "min,max[,step]" do `@export_range`.
static func _read_range(field: Field, hint_string: String) -> void:
	var parts: PackedStringArray = hint_string.split(",")
	if parts.size() < 2:
		return
	field.has_range = true
	field.min_value = parts[0].to_float()
	field.max_value = parts[1].to_float()
	if parts.size() >= 3 and parts[2].is_valid_float():
		field.step = parts[2].to_float()
