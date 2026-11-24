class_name BalanceTable
extends RefCounted
## Valores de balanceamento de uma dificuldade, um por noite (decisão 0031): cada linha é um campo
## numérico ou bool da dificuldade, de um sub-config ou de um evento, e cada coluna é uma noite.
## As linhas saem dos `@export` dos configs: um campo novo vira uma linha nova, com o valor do
## `.tres` em todas as noites.

const FORMAT_VERSION := 1
## Campos que não variam por noite: o `RunState` os copia no começo do plantão.
const HIDDEN_FIELDS: Array[StringName] = [&"nights", &"tutorial_enabled"]
## Tema de cada seção (nome da seção em `ConfigFields.sections`), na ordem em que as linhas
## aparecem. Seção fora da lista cai em `OTHER_THEME`.
const THEMES: Dictionary[String, Array] = {
	"Noite": ["difficulty", "time"],
	"Quebras": ["repair", "events/lamp_burnout", "events/machine_breakdown"],
	"Energia": ["power"],
	"Nevoeiro": ["fog", "events/fog"],
	"Barcos": ["boat", "events/boat"],
	"Afogado": ["drowned", "trapdoor"],
	"Carranca": ["figurehead"],
	"Jogador": ["flashlight", "fall"],
}
const OTHER_THEME := "Outros"

## Número de noites (colunas) da tabela.
var nights: int = 0
## Linhas na ordem dos temas.
var rows: Array[Row] = []

var _by_key: Dictionary[String, Row] = {}


## Monta a tabela da dificuldade com o valor atual de cada campo repetido em todas as noites.
static func from_difficulty(difficulty: DifficultyConfig) -> BalanceTable:
	var table := BalanceTable.new()
	table.nights = difficulty.nights
	var unsorted: Array[Row] = []
	for section: ConfigFields.Section in ConfigFields.sections(difficulty):
		for field: ConfigFields.Field in ConfigFields.fields(section.resource, HIDDEN_FIELDS):
			var row := Row.new()
			row.key = "%s.%s" % [section.label, field.name]
			row.section = section.label
			row.field = field
			row.theme = theme_of(section.label)
			var value: float = float(section.resource.get(field.name))
			for night: int in table.nights:
				row.values.append(value)
			unsorted.append(row)
	for theme: String in theme_names():
		for row: Row in unsorted:
			if row.theme == theme:
				table.rows.append(row)
				table._by_key[row.key] = row
	return table


## Devolve os temas na ordem em que aparecem, com `OTHER_THEME` por último.
static func theme_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(THEMES.keys())
	names.append(OTHER_THEME)
	return names


## Devolve o tema da seção, ou `OTHER_THEME` se ela não estiver em `THEMES`.
static func theme_of(section_label: String) -> String:
	for theme: String in THEMES:
		if THEMES[theme].has(section_label):
			return theme
	return OTHER_THEME


## Devolve a linha da chave (`<seção>.<campo>`), ou null se não houver.
func row(key: String) -> Row:
	return _by_key.get(key)


## Devolve o valor da linha na noite (a primeira é 1), no tipo do campo.
func value(key: String, night: int) -> Variant:
	var target: Row = _by_key[key]
	return target.typed(target.values[night - 1])


## Muda o valor da linha na noite (a primeira é 1).
func set_value(key: String, night: int, new_value: Variant) -> void:
	_by_key[key].values[night - 1] = float(new_value)


## Copia o valor da noite dada para todas as noites seguintes da linha.
func fill_following(key: String, night: int) -> void:
	var target: Row = _by_key[key]
	for index: int in range(night, nights):
		target.values[index] = target.values[night - 1]


## Diz se o valor da noite é diferente do da noite anterior. A primeira noite nunca difere.
func differs_from_previous(key: String, night: int) -> bool:
	if night <= 1:
		return false
	var target: Row = _by_key[key]
	return target.values[night - 1] != target.values[night - 2]


## Escreve os valores da noite (a primeira é 1) nos campos de `difficulty`, que precisa ter as
## mesmas seções da dificuldade que gerou a tabela.
func apply(difficulty: DifficultyConfig, night: int) -> void:
	var resources: Dictionary[String, Resource] = {}
	for section: ConfigFields.Section in ConfigFields.sections(difficulty):
		resources[section.label] = section.resource
	for target: Row in rows:
		var resource: Resource = resources.get(target.section)
		if resource != null:
			resource.set(target.field.name, target.typed(target.values[night - 1]))


## Devolve uma cópia completa de `base` (sub-configs e eventos inclusive) com os valores da noite.
## A `base` e os eventos compartilhados entre dificuldades não mudam.
func config_for_night(base: DifficultyConfig, night: int) -> DifficultyConfig:
	var copy := base.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as DifficultyConfig
	apply(copy, clampi(night, 1, nights))
	return copy


## Lê os valores de um dicionário no formato de `to_json_text`. Linha que falta mantém o valor
## atual; linha com menos noites repete o último valor dado; linha com mais noites é cortada.
## Devolve um aviso por chave desconhecida.
func load_values(data: Dictionary) -> PackedStringArray:
	var warnings := PackedStringArray()
	var saved: Dictionary = data.get("rows", {})
	for key: Variant in saved:
		var target: Row = _by_key.get(str(key))
		var saved_values: Array = saved[key] if saved[key] is Array else []
		if target == null or saved_values.is_empty():
			warnings.append("linha desconhecida ou vazia: %s" % key)
			continue
		for index: int in nights:
			var source: int = mini(index, saved_values.size() - 1)
			target.values[index] = float(saved_values[source])
	return warnings


## Devolve a tabela em JSON com uma linha do arquivo por linha da tabela, para ler e comparar no
## git.
func to_json_text() -> String:
	var lines := PackedStringArray()
	for target: Row in rows:
		var cells := PackedStringArray()
		for cell: float in target.values:
			cells.append(JSON.stringify(target.typed(cell)))
		lines.append('\t\t"%s": [%s]' % [target.key, ", ".join(cells)])
	return (
		'{\n\t"version": %d,\n\t"nights": %d,\n\t"rows": {\n%s\n\t}\n}\n'
		% [FORMAT_VERSION, nights, ",\n".join(lines)]
	)


## Uma linha da tabela: o campo de uma seção e o valor dele em cada noite.
class Row:
	extends RefCounted
	## `<seção>.<campo>`, ex.: `fog.advance_per_second`, `events/boat.chance_per_check`.
	var key: String
	var section: String
	var field: ConfigFields.Field
	var theme: String
	## Um valor por noite, guardado como float; `typed` devolve no tipo do campo.
	var values: Array[float] = []

	## Converte o valor guardado para o tipo do campo (int arredondado, bool acima de 0,5).
	func typed(stored: float) -> Variant:
		match field.type:
			TYPE_INT:
				return roundi(stored)
			TYPE_BOOL:
				return stored > 0.5
		return stored
