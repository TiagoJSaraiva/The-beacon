class_name Radio
extends Node3D
## Rádio da mesa: toca enquanto um barco precisa de aviso no nevoeiro. Atender confirma
## por som; quem decide o efeito é o BoatDirector. Funciona sem energia.

signal answered

@export var blink_interval_seconds: float = 0.5
@export var reply_message: AudioStream

var is_ringing: bool = false

var _blink_time: float = 0.0

@onready var _ring: LoopingSound = %Ring
@onready var _message: AudioStreamPlayer3D = %Message
@onready var _call_light: OmniLight3D = %CallLight
@onready var _answer_point: Interactable = %AnswerPoint


## Começa sem tocar.
func _ready() -> void:
	set_ringing(false)


## Pisca a luz enquanto o rádio toca.
func _process(delta: float) -> void:
	if not is_ringing:
		return
	_blink_time += delta
	_call_light.visible = fmod(_blink_time, blink_interval_seconds * 2.0) < blink_interval_seconds


## Liga ou desliga o toque, a luz e o ponto de atender, que só fica ativo tocando.
func set_ringing(ringing: bool) -> void:
	is_ringing = ringing
	_blink_time = 0.0
	_ring.set_active(ringing)
	_call_light.visible = ringing
	_answer_point.enabled = ringing


## Para o toque, responde por som e emite `answered`.
func _on_answer_point_interacted() -> void:
	set_ringing(false)
	_message.stream = reply_message
	_message.play()
	answered.emit()
