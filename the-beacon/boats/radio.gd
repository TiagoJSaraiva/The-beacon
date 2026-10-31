class_name Radio
extends Node3D
## Rádio da torre: toca quando um barco se aproxima; atender revela, só por som, se o barco
## é permitido ou pirata (GDD 1.2.26). Não depende do gerador.

signal answered(is_pirate: bool)

@export var blink_interval_seconds: float = 0.5
@export var allowed_message: AudioStream
@export var pirate_message: AudioStream

var is_ringing: bool = false

var _incoming_is_pirate: bool = false
var _blink_time: float = 0.0

@onready var _ring: LoopingSound = %Ring
@onready var _message: AudioStreamPlayer3D = %Message
@onready var _call_light: OmniLight3D = %CallLight
@onready var _answer_point: Interactable = %AnswerPoint


func _ready() -> void:
	_set_ringing(false)


func _process(delta: float) -> void:
	if not is_ringing:
		return
	_blink_time += delta
	_call_light.visible = fmod(_blink_time, blink_interval_seconds * 2.0) < blink_interval_seconds


func ring(is_pirate: bool) -> void:
	_incoming_is_pirate = is_pirate
	_set_ringing(true)


func stop_ringing() -> void:
	_set_ringing(false)


func _set_ringing(ringing: bool) -> void:
	is_ringing = ringing
	_blink_time = 0.0
	_ring.set_active(ringing)
	_call_light.visible = ringing
	_answer_point.enabled = ringing


func _on_answer_point_interacted() -> void:
	_set_ringing(false)
	_message.stream = pirate_message if _incoming_is_pirate else allowed_message
	_message.play()
	answered.emit(_incoming_is_pirate)
