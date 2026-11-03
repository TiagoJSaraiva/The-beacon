class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa: andar, correr, pular, olhar (mouse ou analógico direito) e
## sentar na cadeira da mesa.

signal died(cause: StringName)
signal sprint_blocked_changed(active: bool)

const CAUSE_FALL := &"fall"
const CAUSE_DROWNED := &"drowned"

@export var walk_speed: float = 3.5
@export var sprint_speed: float = 5.5
@export var acceleration: float = 12.0
## Velocidade vertical ao pular: cerca de 0,8 m de altura com a gravidade padrão.
@export var jump_velocity: float = 4.0
@export var mouse_sensitivity: float = 0.0025
## Giro com o analógico direito todo inclinado, antes da escala das configurações.
@export var stick_look_degrees_per_second: float = 150.0
@export_range(10.0, 89.0) var max_pitch_degrees: float = 85.0
@export var seated_head_height: float = 1.15
@export var head_transition_speed: float = 3.0

var is_dead: bool = false
var is_seated: bool = false
## Multiplica a sensibilidade do mouse e do analógico; vem das configurações do jogador.
var sensitivity_scale: float = 1.0

var _controls_enabled: bool = true
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _standing_head_height: float = 0.0
var _seat_yaw: float = 0.0
var _seat_yaw_limit: float = 0.0

@onready var interaction: InteractionRay = %InteractionRay
@onready var flashlight: Flashlight = %Flashlight
@onready var _head: Node3D = $Head
@onready var _fall_damage: FallDamage = %FallDamage
@onready var _carried_jerrycan: Node3D = %CarriedJerrycan


func _ready() -> void:
	_standing_head_height = _head.position.y
	_capture_mouse(true)


func _unhandled_input(event: InputEvent) -> void:
	if not _controls_enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion := event as InputEventMouseMotion
	if motion == null:
		return
	_look(motion.relative * mouse_sensitivity * sensitivity_scale)


func _process(delta: float) -> void:
	if not _controls_enabled:
		return
	var stick: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if stick.is_zero_approx():
		return
	_look(stick * deg_to_rad(stick_look_degrees_per_second) * sensitivity_scale * delta)


func _physics_process(delta: float) -> void:
	var target_head: float = seated_head_height if is_seated else _standing_head_height
	_head.position.y = move_toward(_head.position.y, target_head, head_transition_speed * delta)

	var input := Vector2.ZERO
	var jump_pressed: bool = false
	if _controls_enabled:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		jump_pressed = Input.is_action_just_pressed("jump")
	if is_seated:
		# Mover ou pular só levanta; o movimento começa no frame seguinte.
		if not input.is_zero_approx() or jump_pressed:
			is_seated = false
		return

	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif jump_pressed:
		velocity.y = jump_velocity
	# Sem normalizar: o analógico inclinado pela metade anda mais devagar.
	var direction: Vector3 = transform.basis * Vector3(input.x, 0.0, input.y)
	var speed: float = _current_speed()
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(direction * speed, acceleration * speed * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()


## Aplica os parâmetros da dificuldade aos componentes do jogador.
func configure(difficulty: DifficultyConfig) -> void:
	_fall_damage.config = difficulty.fall
	flashlight.configure(difficulty.flashlight)


## Liga ou desliga movimento e olhar (ex.: enquanto o menu de pausa está aberto).
func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	interaction.input_enabled = enabled
	flashlight.input_enabled = enabled
	_capture_mouse(enabled)


## Mostra o galão na mão direita e bloqueia o que exige mãos livres (GDD 1.2.24).
func set_carrying(carrying: bool) -> void:
	_carried_jerrycan.visible = carrying
	interaction.hands_busy = carrying


## Senta com os pés em `seat.origin`, de frente para onde o assento aponta. O olhar vira
## até `yaw_limit_degrees` para cada lado; mover ou pular levanta.
func sit(seat: Transform3D, yaw_limit_degrees: float) -> void:
	if is_seated or is_dead:
		return
	is_seated = true
	velocity = Vector3.ZERO
	global_position = seat.origin
	_seat_yaw = seat.basis.get_euler().y
	_seat_yaw_limit = deg_to_rad(yaw_limit_degrees)
	rotation.y = _seat_yaw
	_head.rotation.x = 0.0


## Mata o jogador uma única vez e trava os controles.
func kill(cause: StringName) -> void:
	if is_dead:
		return
	is_dead = true
	set_controls_enabled(false)
	died.emit(cause)


func _look(turn: Vector2) -> void:
	rotation.y -= turn.x
	if is_seated:
		rotation.y = SeatRules.clamp_yaw(rotation.y, _seat_yaw, _seat_yaw_limit)
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_head.rotation.x = clampf(_head.rotation.x - turn.y, -max_pitch, max_pitch)


func _current_speed() -> float:
	if Input.is_action_pressed("sprint") and not _fall_damage.is_sprint_blocked():
		return sprint_speed
	return walk_speed


func _capture_mouse(captured: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _on_fall_damage_fatal_fall() -> void:
	kill(CAUSE_FALL)


func _on_fall_damage_sprint_blocked_changed(active: bool) -> void:
	sprint_blocked_changed.emit(active)
