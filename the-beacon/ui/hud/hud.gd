class_name Hud
extends CanvasLayer
## HUD mínima: hotkey de interação e barra de progresso (GDD 1.2.21), mais os efeitos de
## tela causados por eventos, que não são informação de estado: cegueira e borda vermelha.

@export var blind_fade_seconds: float = 0.6

var _blind_tween: Tween

@onready var _prompt: Label = %Prompt
@onready var _hold_bar: ProgressBar = %HoldBar
@onready var _blindness: ColorRect = %Blindness
@onready var _slowed_border: Panel = %SlowedBorder


func show_prompt(text: String) -> void:
	_prompt.text = text
	_prompt.visible = not text.is_empty()


func show_hold_progress(ratio: float, active: bool) -> void:
	_hold_bar.value = ratio
	_hold_bar.visible = active


## Tela preta por `seconds` (toque do Homem de Nevoeiro), voltando aos poucos.
func show_blindness(seconds: float) -> void:
	if _blind_tween != null:
		_blind_tween.kill()
	_blindness.modulate.a = 1.0
	_blind_tween = create_tween()
	_blind_tween.tween_interval(maxf(seconds - blind_fade_seconds, 0.0))
	_blind_tween.tween_property(_blindness, "modulate:a", 0.0, blind_fade_seconds)


## Borda vermelha enquanto o jogador está lento por queda.
func set_slowed(active: bool) -> void:
	_slowed_border.visible = active
