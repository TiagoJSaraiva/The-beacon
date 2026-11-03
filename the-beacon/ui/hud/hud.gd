class_name Hud
extends CanvasLayer
## HUD mínima: hotkey de interação, barra de progresso e texto do tutorial (GDD 1.2.21 e
## 9.1), mais os efeitos de tela causados por eventos, que não são informação de estado:
## cegueira e borda vermelha. A tecla de interagir e as marcações `{ação}` do tutorial
## mostram a tecla atual (decisão 0018) do último dispositivo usado.

@export var blind_fade_seconds: float = 0.6
## Inclinação do analógico a partir da qual a HUD passa a mostrar os botões do controle.
@export var joypad_switch_deadzone: float = 0.5

var _blind_tween: Tween
var _using_joypad: bool = false
var _tutorial_template: String = ""

@onready var _prompt: Label = %Prompt
@onready var _hold_bar: ProgressBar = %HoldBar
@onready var _blindness: ColorRect = %Blindness
@onready var _hurt_border: Panel = %HurtBorder
@onready var _tutorial_text: Label = %TutorialText


func _ready() -> void:
	Settings.changed.connect(_refresh_texts)
	_refresh_texts()


func _input(event: InputEvent) -> void:
	var joypad: bool = false
	if event is InputEventJoypadButton:
		joypad = true
	elif event is InputEventJoypadMotion:
		if absf((event as InputEventJoypadMotion).axis_value) < joypad_switch_deadzone:
			return
		joypad = true
	elif not (event is InputEventKey or event is InputEventMouseButton):
		return
	if joypad != _using_joypad:
		_using_joypad = joypad
		_refresh_texts()


func show_prompt(visible_now: bool) -> void:
	_prompt.visible = visible_now


func show_hold_progress(ratio: float, active: bool) -> void:
	_hold_bar.value = ratio
	_hold_bar.visible = active


## Tela preta por `seconds` (pulo da carranca), voltando aos poucos.
func show_blindness(seconds: float) -> void:
	if _blind_tween != null:
		_blind_tween.kill()
	_blindness.modulate.a = 1.0
	_blind_tween = create_tween()
	_blind_tween.tween_interval(maxf(seconds - blind_fade_seconds, 0.0))
	_blind_tween.tween_property(_blindness, "modulate:a", 0.0, blind_fade_seconds)


## Único texto da HUD, e só durante o tutorial. Vazio esconde.
func show_tutorial(text: String) -> void:
	_tutorial_template = text
	_tutorial_text.visible = not text.is_empty()
	_refresh_texts()


## Borda vermelha enquanto a corrida está bloqueada por queda.
func set_hurt_border(active: bool) -> void:
	_hurt_border.visible = active


func _refresh_texts() -> void:
	_prompt.text = Settings.bindings.label_for(&"interact", _using_joypad)
	var text: String = _tutorial_template
	for action: StringName in InputBindings.KEYBOARD_ACTIONS:
		text = text.replace("{%s}" % action, Settings.bindings.label_for(action, _using_joypad))
	_tutorial_text.text = text
