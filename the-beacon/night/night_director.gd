class_name NightDirector
extends Node
## Faz o relógio da noite andar e avisa mudanças de minuto e o fim da noite (06:00).

signal time_changed(display_text: String)
signal night_started(night: int)
signal night_ended(night: int)

## Acelera só o relógio, e só em build de debug, para testar fins de noite rápido.
@export var debug_time_scale: float = 1.0

var clock: NightClock
var current_night: int = 0
var is_running: bool = false

var _shown_text: String = ""


func _process(delta: float) -> void:
	if not is_running:
		return
	var scale: float = debug_time_scale if OS.is_debug_build() else 1.0
	var finished: bool = clock.advance(delta * scale)
	_publish_time()
	if finished:
		is_running = false
		night_ended.emit(current_night)


func configure(config: TimeConfig) -> void:
	clock = NightClock.new(config)


## Começa a noite indicada (a primeira é 1) às 20h.
func start_night(night: int) -> void:
	current_night = night
	clock.reset()
	is_running = true
	_shown_text = ""
	_publish_time()
	night_started.emit(night)


func _publish_time() -> void:
	var text: String = clock.display_text()
	if text == _shown_text:
		return
	_shown_text = text
	time_changed.emit(text)
