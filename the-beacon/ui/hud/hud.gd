class_name Hud
extends CanvasLayer
## HUD mínima: hotkey de interação, barra de progresso e texto do tutorial (GDD 1.2.21 e
## 9.1), mais os efeitos de tela causados por eventos, que não são informação de estado:
## cegueira e borda vermelha.

@export var blind_fade_seconds: float = 0.6

var _blind_tween: Tween

@onready var _prompt: Label = %Prompt
@onready var _hold_bar: ProgressBar = %HoldBar
@onready var _blindness: ColorRect = %Blindness
@onready var _hurt_border: Panel = %HurtBorder
@onready var _tutorial_text: Label = %TutorialText


func show_prompt(text: String) -> void:
	_prompt.text = text
	_prompt.visible = not text.is_empty()


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
	_tutorial_text.text = text
	_tutorial_text.visible = not text.is_empty()


## Borda vermelha enquanto a corrida está bloqueada por queda.
func set_hurt_border(active: bool) -> void:
	_hurt_border.visible = active
