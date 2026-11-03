class_name FallDamage
extends Node
## Mede a altura de cada queda do corpo: uma queda média bloqueia a corrida por um tempo e
## uma queda alta mata.

signal sprint_blocked_changed(active: bool)
signal fatal_fall

@export var body: CharacterBody3D
@export var config: FallConfig

var _airborne: bool = false
var _peak_height: float = 0.0
var _sprint_block_left: float = 0.0


func _ready() -> void:
	if body == null:
		push_warning("FallDamage sem body atribuído")
		set_physics_process(false)
	# O Game atribui a config da dificuldade; o padrão serve para cenas de teste.
	if config == null:
		config = FallConfig.new()


func _physics_process(delta: float) -> void:
	_update_sprint_block(delta)
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
		FallRules.Outcome.SPRINT_BLOCK:
			_block_sprint()


func is_sprint_blocked() -> bool:
	return _sprint_block_left > 0.0


func _block_sprint() -> void:
	var was_blocked: bool = is_sprint_blocked()
	# Outra queda média durante o bloqueio recomeça a contagem.
	_sprint_block_left = config.sprint_block_seconds
	if not was_blocked:
		sprint_blocked_changed.emit(true)


func _update_sprint_block(delta: float) -> void:
	if not is_sprint_blocked():
		return
	_sprint_block_left -= delta
	if not is_sprint_blocked():
		sprint_blocked_changed.emit(false)
