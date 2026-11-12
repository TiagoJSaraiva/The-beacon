class_name ConfigEditor
extends VBoxContainer
## Linhas de edição de um `Resource` de configuração: SpinBox para número e CheckBox para bool,
## montadas pelos campos de `ConfigFields`. Cada mudança é escrita no recurso na hora.

## Limite das SpinBox de campos sem `@export_range`.
const OPEN_LIMIT := 100000.0
const FLOAT_STEP := 0.001
## Marca os campos que só valem ao recomeçar a noite.
const RESTART_MARK := " *"

var _resource: Resource
var _inputs: Dictionary[StringName, Control] = {}


## Monta uma linha por campo de `resource`, sem os de `hidden`. Os campos em `restart_only`
## ganham a marca de "vale ao recomeçar a noite".
func build(resource: Resource, hidden: Array[StringName], restart_only: Array[StringName]) -> void:
	_resource = resource
	var group: String = ""
	for field: ConfigFields.Field in ConfigFields.fields(resource, hidden):
		if field.group != group:
			group = field.group
			_add_group_label(group)
		var label_text: String = field.name
		if field.name in restart_only:
			label_text += RESTART_MARK
		_add_row(field, label_text)


## Relê os valores do recurso nas linhas (ex.: depois de restaurar os originais).
func refresh() -> void:
	for field_name: StringName in _inputs:
		var input: Control = _inputs[field_name]
		var value: Variant = _resource.get(field_name)
		if input is CheckBox:
			(input as CheckBox).set_pressed_no_signal(value)
		else:
			(input as SpinBox).set_value_no_signal(value)


## Acrescenta o nome do `@export_group` acima dos campos dele.
func _add_group_label(group: String) -> void:
	var label := Label.new()
	label.text = "· %s" % group
	label.modulate = Color(1.0, 1.0, 1.0, 0.6)
	add_child(label)


## Acrescenta a linha do campo, ligada ao recurso.
func _add_row(field: ConfigFields.Field, label_text: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var input: Control = (
		_make_check_box(field) if field.type == TYPE_BOOL else _make_spin_box(field)
	)
	row.add_child(input)
	_inputs[field.name] = input
	add_child(row)


## Cria a CheckBox do campo bool.
func _make_check_box(field: ConfigFields.Field) -> CheckBox:
	var check := CheckBox.new()
	check.button_pressed = _resource.get(field.name)
	check.toggled.connect(func(pressed: bool) -> void: _resource.set(field.name, pressed))
	return check


## Cria a SpinBox do campo numérico, com a faixa do `@export_range` ou aberta.
func _make_spin_box(field: ConfigFields.Field) -> SpinBox:
	var spin := SpinBox.new()
	spin.custom_minimum_size.x = 120.0
	if field.has_range:
		spin.min_value = field.min_value
		spin.max_value = field.max_value
	else:
		spin.min_value = -OPEN_LIMIT
		spin.max_value = OPEN_LIMIT
	var is_int: bool = field.type == TYPE_INT
	if is_int:
		spin.step = 1.0
	else:
		spin.step = field.step if field.step > 0.0 else FLOAT_STEP
	spin.value = _resource.get(field.name)
	spin.value_changed.connect(
		func(value: float) -> void: _resource.set(field.name, int(value) if is_int else value)
	)
	return spin
