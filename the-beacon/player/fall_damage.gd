class_name FallDamage
extends Node
## Mede a altura de cada queda do corpo e informa lentidão ou queda fatal.

signal slowed(seconds: float, speed_multiplier: float)
signal fatal_fall

@export var body: CharacterBody3D
@export var config: FallConfig

var _airborne: bool = false
var _peak_height: float = 0.0


func _ready() -> void:
	if body == null:
		push_warning("FallDamage sem body atribuído")
		set_physics_process(false)
	# O Game atribui a config da dificuldade; o padrão serve para cenas de teste.
	if config == null:
		config = FallConfig.new()


func _physics_process(_delta: float) -> void:
	var height: float = body.global_position.y
	if not body.is_on_floor():
		if not _airborne:
			_airborne = true
			_peak_height = height
		_peak_height = maxf(_peak_height, height)
		return
	if not _airborne:
		return
	_airborne = false
	match FallRules.evaluate(_peak_height - height, config):
		FallRules.Outcome.FATAL:
			fatal_fall.emit()
		FallRules.Outcome.SLOW:
			slowed.emit(config.slow_seconds, config.slow_speed_multiplier)
