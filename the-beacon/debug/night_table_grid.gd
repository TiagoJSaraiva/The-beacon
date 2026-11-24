class_name NightTableGrid
extends GridContainer
## Grade da tabela de balanceamento de uma dificuldade (decisão 0031): uma linha por valor,
## agrupada por tema, e uma coluna por noite. Cada célula escreve na tabela na hora e fica
## colorida quando o valor muda em relação à noite anterior.

## O testador mudou a célula; a tabela já tem o valor novo.
signal cell_changed(key: String, night: int)

const TITLE_COLOR := Color(0.85, 0.65, 0.2)
const CURRENT_NIGHT_COLOR := Color(0.45, 0.8, 1.0)
## Célula com valor diferente do da noite anterior.
const CHANGED_COLOR := Color(1.0, 0.7, 0.35)
const LABEL_WIDTH := 330.0
const CELL_WIDTH := 96.0
## Limite das células de campos sem `@export_range`.
const OPEN_LIMIT := 100000.0
const FLOAT_STEP := 0.001
## Marca as linhas que só valem ao recomeçar a noite.
const RESTART_MARK := " *"

## Linha e noite da última célula editada ou focada; vazio antes de qualquer uma.
var last_key: String = ""
var last_night: int = 0

var _table: BalanceTable
var _cells: Dictionary[String, Control] = {}


## Monta a grade da tabela, destacando a coluna de `current_night` (0 = nenhuma) e marcando as
## linhas de `restart_keys`. Substitui a grade anterior.
func build(table: BalanceTable, current_night: int, restart_keys: Array[String]) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_cells.clear()
	_table = table
	last_key = ""
	last_night = 0
	columns = table.nights + 1
	_add_header(current_night)
	var theme: String = ""
	for row: BalanceTable.Row in table.rows:
		if row.theme != theme:
			theme = row.theme
			_add_theme_title(theme)
		var label_text: String = row.key
		if row.key in restart_keys:
			label_text += RESTART_MARK
		_add_label(label_text, Color.WHITE)
		for night: int in range(1, table.nights + 1):
			var cell: Control = _make_cell(row, night)
			_cells[_cell_id(row.key, night)] = cell
			add_child(cell)
			_tint(row.key, night)


## Relê da tabela os valores e as cores de todas as células.
func refresh() -> void:
	for row: BalanceTable.Row in _table.rows:
		for night: int in range(1, _table.nights + 1):
			var cell: Control = _cells[_cell_id(row.key, night)]
			var value: Variant = _table.value(row.key, night)
			if cell is CheckBox:
				(cell as CheckBox).set_pressed_no_signal(value)
			else:
				(cell as SpinBox).set_value_no_signal(value)
			_tint(row.key, night)


## Devolve a célula da linha na noite (SpinBox ou CheckBox), ou null se não houver.
func cell(key: String, night: int) -> Control:
	return _cells.get(_cell_id(key, night))


## Acrescenta a linha de cabeçalho com o número de cada noite.
func _add_header(current_night: int) -> void:
	_add_label("", Color.WHITE)
	for night: int in range(1, _table.nights + 1):
		if night == current_night:
			_add_label("▶ Noite %d" % night, CURRENT_NIGHT_COLOR)
		else:
			_add_label("Noite %d" % night, Color.WHITE)


## Acrescenta a linha com o nome do tema, sem células.
func _add_theme_title(theme: String) -> void:
	_add_label(theme, TITLE_COLOR)
	for night: int in _table.nights:
		add_child(Control.new())


## Acrescenta um rótulo na próxima posição da grade.
func _add_label(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size.x = LABEL_WIDTH if get_child_count() % columns == 0 else CELL_WIDTH
	add_child(label)


## Cria a célula da linha na noite: CheckBox para bool, SpinBox para número.
func _make_cell(row: BalanceTable.Row, night: int) -> Control:
	if row.field.type == TYPE_BOOL:
		var check := CheckBox.new()
		check.button_pressed = _table.value(row.key, night)
		check.toggled.connect(func(pressed: bool) -> void: _write(row.key, night, pressed))
		check.focus_entered.connect(_remember.bind(row.key, night))
		return check
	var spin := SpinBox.new()
	spin.custom_minimum_size.x = CELL_WIDTH
	spin.select_all_on_focus = true
	spin.min_value = row.field.min_value if row.field.has_range else -OPEN_LIMIT
	spin.max_value = row.field.max_value if row.field.has_range else OPEN_LIMIT
	if row.field.type == TYPE_INT:
		spin.step = 1.0
	else:
		spin.step = row.field.step if row.field.step > 0.0 else FLOAT_STEP
	spin.value = _table.value(row.key, night)
	spin.value_changed.connect(func(value: float) -> void: _write(row.key, night, value))
	spin.get_line_edit().focus_entered.connect(_remember.bind(row.key, night))
	return spin


## Escreve o valor na tabela, recolore a célula e a da noite seguinte e emite `cell_changed`.
func _write(key: String, night: int, value: Variant) -> void:
	_table.set_value(key, night, value)
	_remember(key, night)
	_tint(key, night)
	if night < _table.nights:
		_tint(key, night + 1)
	cell_changed.emit(key, night)


## Guarda a célula como a última usada, para "Copiar para as noites seguintes".
func _remember(key: String, night: int) -> void:
	last_key = key
	last_night = night


## Colore a célula se o valor muda em relação à noite anterior.
func _tint(key: String, night: int) -> void:
	var changed: bool = _table.differs_from_previous(key, night)
	_cells[_cell_id(key, night)].modulate = CHANGED_COLOR if changed else Color.WHITE


## Devolve a chave da célula no dicionário de células.
func _cell_id(key: String, night: int) -> String:
	return "%s|%d" % [key, night]
