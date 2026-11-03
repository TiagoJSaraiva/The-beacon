class_name ControlsPanel
extends VBoxContainer
## Remapeamento (decisão 0018): uma linha por ação, com a tecla e o botão do controle atuais.
## Ativar um deles espera a nova tecla ou o novo botão; Esc cancela. As mudanças valem na
## hora e são gravadas ao voltar.

signal back_requested

const ACTION_NAMES: Dictionary = {
	&"move_forward": "Andar para frente",
	&"move_back": "Andar para trás",
	&"move_left": "Andar para a esquerda",
	&"move_right": "Andar para a direita",
	&"jump": "Pular",
	&"sprint": "Correr",
	&"interact": "Interagir",
	&"toggle_flashlight": "Lanterna",
	&"check_battery": "Ver a bateria",
	&"drop_item": "Soltar o galão",
	&"pause": "Pausa",
}
const WAITING_TEXT := "Aperte…"

var _waiting_action: StringName = &""
var _waiting_joypad: bool = false
var _key_buttons: Dictionary[StringName, Button] = {}
var _joypad_buttons: Dictionary[StringName, Button] = {}
var _joypad_labels: Dictionary[StringName, Label] = {}

@onready var _grid: GridContainer = %Grid


func _ready() -> void:
	_build_rows()
	Settings.changed.connect(refresh)
	refresh()


## Captura antes dos menus, para Esc e os botões não fecharem nada durante a espera.
func _input(event: InputEvent) -> void:
	if _waiting_action == &"" or not event.is_pressed() or event.is_echo():
		return
	var key := event as InputEventKey
	var button := event as InputEventJoypadButton
	if key == null and button == null:
		return
	get_viewport().set_input_as_handled()
	if key != null and key.physical_keycode == KEY_ESCAPE:
		_stop_waiting()
	elif key != null and not _waiting_joypad:
		var action: StringName = _waiting_action
		_stop_waiting()
		Settings.set_key_binding(action, key.physical_keycode)
	elif button != null and _waiting_joypad:
		var action: StringName = _waiting_action
		_stop_waiting()
		Settings.set_button_binding(action, button.button_index)


## Mostra as ligações atuais.
func refresh() -> void:
	for action: StringName in _key_buttons:
		_key_buttons[action].text = Settings.bindings.label_for(action, false)
	for action: StringName in _joypad_buttons:
		_joypad_buttons[action].text = Settings.bindings.label_for(action, true)
	for action: StringName in _joypad_labels:
		_joypad_labels[action].text = Settings.bindings.label_for(action, true)


func focus_first() -> void:
	_key_buttons[InputBindings.KEYBOARD_ACTIONS[0]].grab_focus()


func _build_rows() -> void:
	for action: StringName in InputBindings.KEYBOARD_ACTIONS:
		var name_label := Label.new()
		name_label.text = ACTION_NAMES.get(action, String(action))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_grid.add_child(name_label)
		_key_buttons[action] = _add_binding_button(action, false)
		if InputBindings.JOYPAD_ACTIONS.has(action):
			_joypad_buttons[action] = _add_binding_button(action, true)
		else:
			var fixed := Label.new()
			fixed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_grid.add_child(fixed)
			_joypad_labels[action] = fixed


func _add_binding_button(action: StringName, joypad: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(150, 0)
	button.pressed.connect(_start_waiting.bind(action, joypad))
	_grid.add_child(button)
	return button


func _start_waiting(action: StringName, joypad: bool) -> void:
	refresh()
	_waiting_action = action
	_waiting_joypad = joypad
	var buttons: Dictionary[StringName, Button] = _joypad_buttons if joypad else _key_buttons
	buttons[action].text = WAITING_TEXT


func _stop_waiting() -> void:
	_waiting_action = &""
	refresh()


func _on_reset_button_pressed() -> void:
	_stop_waiting()
	Settings.reset_bindings()


func _on_back_button_pressed() -> void:
	_stop_waiting()
	Settings.save()
	back_requested.emit()
