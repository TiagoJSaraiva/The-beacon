class_name InputBindings
extends RefCounted
## Teclas e botões remapeáveis (decisão 0018). Guarda os códigos (tecla física e botão de
## controle); quem aplica no InputMap é o autoload Settings.

## Ações de jogo com tecla remapeável.
const KEYBOARD_ACTIONS: Array[StringName] = [
	&"move_forward",
	&"move_back",
	&"move_left",
	&"move_right",
	&"jump",
	&"sprint",
	&"interact",
	&"toggle_flashlight",
	&"check_battery",
	&"drop_item",
	&"pause",
]
## Ações de jogo com botão de controle remapeável. As outras usam analógico ou gatilho.
const JOYPAD_ACTIONS: Array[StringName] = [
	&"jump",
	&"interact",
	&"toggle_flashlight",
	&"check_battery",
	&"drop_item",
	&"pause",
]
const DEFAULT_KEYS: Dictionary = {
	&"move_forward": KEY_W,
	&"move_back": KEY_S,
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"jump": KEY_SPACE,
	&"sprint": KEY_SHIFT,
	&"interact": KEY_E,
	&"toggle_flashlight": KEY_Q,
	&"check_battery": KEY_X,
	&"drop_item": KEY_R,
	&"pause": KEY_ESCAPE,
}
const DEFAULT_BUTTONS: Dictionary = {
	&"jump": JOY_BUTTON_A,
	&"interact": JOY_BUTTON_Y,
	&"toggle_flashlight": JOY_BUTTON_X,
	&"check_battery": JOY_BUTTON_DPAD_UP,
	&"drop_item": JOY_BUTTON_B,
	&"pause": JOY_BUTTON_START,
}
## Controle das ações que não usam botão remapeável.
const FIXED_JOYPAD_LABELS: Dictionary = {
	&"move_forward": "Analógico esquerdo",
	&"move_back": "Analógico esquerdo",
	&"move_left": "Analógico esquerdo",
	&"move_right": "Analógico esquerdo",
	&"sprint": "L2",
}
## Nomes no padrão Xbox (os botões de face valem pela posição).
const BUTTON_NAMES: Dictionary = {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_GUIDE: "Guide",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "L3",
	JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-pad cima",
	JOY_BUTTON_DPAD_DOWN: "D-pad baixo",
	JOY_BUTTON_DPAD_LEFT: "D-pad esquerda",
	JOY_BUTTON_DPAD_RIGHT: "D-pad direita",
}

var keys: Dictionary[StringName, int] = {}
var buttons: Dictionary[StringName, int] = {}


func _init() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	keys.clear()
	for action: StringName in KEYBOARD_ACTIONS:
		keys[action] = DEFAULT_KEYS[action]
	buttons.clear()
	for action: StringName in JOYPAD_ACTIONS:
		buttons[action] = DEFAULT_BUTTONS[action]


func bind_key(action: StringName, physical_keycode: int) -> void:
	_bind(keys, action, physical_keycode)


func bind_button(action: StringName, button: int) -> void:
	_bind(buttons, action, button)


## Rótulo da tecla ou do botão atual da ação.
func label_for(action: StringName, joypad: bool) -> String:
	if joypad:
		if buttons.has(action):
			return BUTTON_NAMES.get(buttons[action], "Botão %d" % buttons[action])
		return FIXED_JOYPAD_LABELS.get(action, "")
	if not keys.has(action):
		return ""
	var keycode: Key = DisplayServer.keyboard_get_keycode_from_physical(keys[action])
	return OS.get_keycode_string(keycode)


func to_dict() -> Dictionary:
	return {"keys": _codes_to_dict(keys), "buttons": _codes_to_dict(buttons)}


## Lê o que o arquivo trouxer. Valor inválido ou repetido volta tudo ao padrão.
func from_dict(data: Dictionary) -> void:
	reset_to_defaults()
	var loaded_keys: Variant = data.get("keys", {})
	var loaded_buttons: Variant = data.get("buttons", {})
	if loaded_keys is Dictionary:
		_read_codes(keys, loaded_keys)
	if loaded_buttons is Dictionary:
		_read_codes(buttons, loaded_buttons)
	if _has_invalid(keys, 1) or _has_invalid(buttons, 0):
		reset_to_defaults()


## Dar a uma ação o código de outra troca os dois.
static func _bind(codes: Dictionary[StringName, int], action: StringName, code: int) -> void:
	if not codes.has(action):
		return
	for other: StringName in codes:
		if other != action and codes[other] == code:
			codes[other] = codes[action]
	codes[action] = code


static func _codes_to_dict(codes: Dictionary[StringName, int]) -> Dictionary:
	var result: Dictionary = {}
	for action: StringName in codes:
		result[String(action)] = codes[action]
	return result


static func _read_codes(codes: Dictionary[StringName, int], loaded: Dictionary) -> void:
	for action: StringName in codes:
		var value: Variant = loaded.get(String(action))
		if value is int or value is float:
			codes[action] = int(value)


## Códigos abaixo de `min_code` ou repetidos.
static func _has_invalid(codes: Dictionary[StringName, int], min_code: int) -> bool:
	var seen: Array[int] = []
	for action: StringName in codes:
		var code: int = codes[action]
		if code < min_code or seen.has(code):
			return true
		seen.append(code)
	return false
