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


## Monta as linhas das ações, passa a acompanhar as mudanças e mostra as ligações atuais.
func _ready() -> void:
	_build_rows()
	Settings.changed.connect(refresh)
	refresh()


## Captura a tecla ou o botão esperado antes dos menus, para Esc e os botões não fecharem nada
## durante a espera. Esc cancela.
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


## Põe o foco na tecla da primeira ação.
func focus_first() -> void:
	_key_buttons[InputBindings.KEYBOARD_ACTIONS[0]].grab_focus()


## Cria uma linha por ação: nome, tecla e botão de controle, ou o texto fixo das ações sem botão
## remapeável.
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


## Cria o botão que inicia a espera da nova tecla ou do novo botão e o devolve.
func _add_binding_button(action: StringName, joypad: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(150, 0)
	button.pressed.connect(_start_waiting.bind(action, joypad))
	_grid.add_child(button)
	return button


## Passa a esperar a nova tecla ou botão da ação e mostra o aviso no botão dela.
func _start_waiting(action: StringName, joypad: bool) -> void:
	refresh()
	_waiting_action = action
	_waiting_joypad = joypad
	var buttons: Dictionary[StringName, Button] = _joypad_buttons if joypad else _key_buttons
	buttons[action].text = WAITING_TEXT


## Encerra a espera e mostra as ligações atuais.
func _stop_waiting() -> void:
	_waiting_action = &""
	refresh()


## Cancela a espera e volta os controles ao padrão.
func _on_reset_button_pressed() -> void:
	_stop_waiting()
	Settings.reset_bindings()


## Cancela a espera, grava as configurações e pede para voltar.
func _on_back_button_pressed() -> void:
	_stop_waiting()
	Settings.save()
	back_requested.emit()
