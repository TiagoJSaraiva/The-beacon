class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa: andar, correr, agachar e olhar. Não há pulo (GDD 1.2.20).

signal died(cause: StringName)
signal slowed_changed(active: bool)

const CAUSE_FALL := &"fall"
const CAUSE_DROWNED := &"drowned"

@export var walk_speed: float = 3.5
@export var sprint_speed: float = 5.5
@export var crouch_speed: float = 1.6
@export var acceleration: float = 12.0
@export var standing_head_height: float = 1.6
@export var crouching_head_height: float = 1.0
@export var crouch_transition_speed: float = 8.0
@export var mouse_sensitivity: float = 0.0025
@export_range(10.0, 89.0) var max_pitch_degrees: float = 85.0

var is_dead: bool = false

var _controls_enabled: bool = true
var _speed_multiplier: float = 1.0
var _slow_time_left: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var interaction: InteractionRay = %InteractionRay
@onready var flashlight: Flashlight = %Flashlight
@onready var _head: Node3D = $Head
@onready var _fall_damage: FallDamage = %FallDamage
@onready var _carried_jerrycan: Node3D = %CarriedJerrycan


func _ready() -> void:
	_capture_mouse(true)


func _unhandled_input(event: InputEvent) -> void:
	# Só em debug: libera o mouse para o desenvolvedor sair da janela, já que o jogo não tem pausa.
	if OS.is_debug_build() and event.is_action_pressed("ui_cancel"):
		_capture_mouse(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED)
		return
	if not _controls_enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion := event as InputEventMouseMotion
	if motion == null:
		return
	rotate_y(-motion.relative.x * mouse_sensitivity)
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_head.rotation.x = clampf(
		_head.rotation.x - motion.relative.y * mouse_sensitivity, -max_pitch, max_pitch
	)


func _physics_process(delta: float) -> void:
	_update_slow(delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	var crouching: bool = _controls_enabled and Input.is_action_pressed("crouch")
	var target_head: float = crouching_head_height if crouching else standing_head_height
	_head.position.y = move_toward(_head.position.y, target_head, crouch_transition_speed * delta)

	var direction := Vector3.ZERO
	if _controls_enabled:
		var input: Vector2 = Input.get_vector(
			"move_left", "move_right", "move_forward", "move_back"
		)
		direction = (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var speed: float = _current_speed(crouching) * _speed_multiplier
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(direction * speed, acceleration * speed * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()


## Aplica os parâmetros da dificuldade aos componentes do jogador.
func configure(difficulty: DifficultyConfig) -> void:
	_fall_damage.config = difficulty.fall
	flashlight.configure(difficulty.flashlight)


## Liga ou desliga movimento e olhar (ex.: enquanto a agenda está aberta).
func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	interaction.input_enabled = enabled
	flashlight.input_enabled = enabled
	_capture_mouse(enabled)


## Mostra o galão na mão direita e bloqueia o que exige mãos livres (GDD 1.2.24).
func set_carrying(carrying: bool) -> void:
	_carried_jerrycan.visible = carrying
	interaction.hands_busy = carrying


## Mata o jogador uma única vez e trava os controles.
func kill(cause: StringName) -> void:
	if is_dead:
		return
	is_dead = true
	set_controls_enabled(false)
	died.emit(cause)


func apply_slow(seconds: float, speed_multiplier: float) -> void:
	_slow_time_left = maxf(_slow_time_left, seconds)
	_speed_multiplier = speed_multiplier
	slowed_changed.emit(true)


func _current_speed(crouching: bool) -> float:
	if crouching:
		return crouch_speed
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return walk_speed


func _update_slow(delta: float) -> void:
	if _slow_time_left <= 0.0:
		return
	_slow_time_left -= delta
	if _slow_time_left <= 0.0:
		_speed_multiplier = 1.0
		slowed_changed.emit(false)


func _capture_mouse(captured: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _on_fall_damage_fatal_fall() -> void:
	kill(CAUSE_FALL)


func _on_fall_damage_slowed(seconds: float, speed_multiplier: float) -> void:
	apply_slow(seconds, speed_multiplier)
