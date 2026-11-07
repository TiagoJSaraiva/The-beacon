class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa: andar, correr, pular, olhar (mouse ou analógico direito),
## sentar na cadeira da mesa e ser derrubado pela carranca.

signal died(cause: StringName)
signal sprint_blocked_changed(active: bool)
## Soltar o galão da mão em `at`, com a velocidade do arremesso.
signal drop_requested(at: Vector3, throw_velocity: Vector3)

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
@export var kneeling_head_height: float = 0.8
@export var head_transition_speed: float = 3.0
## Velocidade com que o galão sai da mão ao ser solto (um arremesso leve).
@export var drop_throw_speed: float = 1.5
## Distância que o galão solto fica de uma parede à frente.
@export var drop_wall_margin: float = 0.25

var is_dead: bool = false
var is_seated: bool = false
var is_knocked_down: bool = false
## Multiplica a sensibilidade do mouse e do analógico; vem das configurações do jogador.
var sensitivity_scale: float = 1.0

var _controls_enabled: bool = true
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _standing_head_height: float = 0.0
var _seat_yaw: float = 0.0
var _seat_yaw_limit: float = 0.0
var _knockdown_left: float = 0.0

@onready var interaction: InteractionRay = %InteractionRay
@onready var flashlight: Flashlight = %Flashlight
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _fall_damage: FallDamage = %FallDamage
@onready var _carried_jerrycan: Node3D = %CarriedJerrycan


## Guarda a altura da cabeça em pé, liga o pedido de soltar o galão e captura o mouse.
func _ready() -> void:
	_standing_head_height = _head.position.y
	interaction.drop_requested.connect(_request_drop)
	_capture_mouse(true)


## Vira o olhar com o movimento do mouse, se os controles estiverem ligados e o mouse capturado.
func _unhandled_input(event: InputEvent) -> void:
	if not _controls_enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion := event as InputEventMouseMotion
	if motion == null:
		return
	_look(motion.relative * mouse_sensitivity * sensitivity_scale)


## Vira o olhar com o analógico direito.
func _process(delta: float) -> void:
	if not _controls_enabled:
		return
	var stick: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if stick.is_zero_approx():
		return
	_look(stick * deg_to_rad(stick_look_degrees_per_second) * sensitivity_scale * delta)


## Atualiza a derrubada e a altura da cabeça, lê o input e move o corpo. Sentado, não se move:
## mover ou pular só levanta. Derrubado, ignora andar e pular.
func _physics_process(delta: float) -> void:
	_update_knockdown(delta)
	_head.position.y = move_toward(
		_head.position.y, _target_head_height(), head_transition_speed * delta
	)

	var input := Vector2.ZERO
	var jump_pressed: bool = false
	if _controls_enabled:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		jump_pressed = Input.is_action_just_pressed("jump")
		if interaction.hands_busy and Input.is_action_just_pressed("drop_item"):
			_request_drop()
	if is_seated:
		# Mover ou pular só levanta; o movimento começa no frame seguinte.
		if not input.is_zero_approx() or jump_pressed:
			is_seated = false
		return

	if is_knocked_down:
		input = Vector2.ZERO
		jump_pressed = false
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


## Derruba o jogador por `seconds`, ou pelo tempo que ainda restar, se for maior: ajoelha, sai da
## cadeira e não anda nem pula, mas o olhar continua livre.
func knock_down(seconds: float) -> void:
	is_seated = false
	is_knocked_down = true
	_knockdown_left = maxf(_knockdown_left, seconds)


## Devolve a posição e a direção da câmera, o olho do jogador.
func eye_transform() -> Transform3D:
	return _camera.global_transform


## Mata o jogador uma única vez e trava os controles.
func kill(cause: StringName) -> void:
	if is_dead:
		return
	is_dead = true
	set_controls_enabled(false)
	died.emit(cause)


## Calcula o ponto e a velocidade de saída do galão e emite `drop_requested`. Quem solta de fato
## é o farol.
func _request_drop() -> void:
	var forward: Vector3 = -_camera.global_basis.z
	var at: Vector3 = _carried_jerrycan.global_position
	# Colado numa parede, o galão nasceria dentro dela: recua até a frente do obstáculo.
	var query := PhysicsRayQueryParameters3D.create(
		_camera.global_position, at, CollisionLayers.WORLD | CollisionLayers.BARRIERS
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		at = hit["position"] - forward * drop_wall_margin
	var carried_velocity := Vector3(velocity.x, 0.0, velocity.z)
	drop_requested.emit(at, carried_velocity + forward * drop_throw_speed)


## Gira o corpo no eixo Y e a cabeça no eixo X, em radianos, respeitando os limites do olhar e o
## limite sentado.
func _look(turn: Vector2) -> void:
	rotation.y -= turn.x
	if is_seated:
		rotation.y = SeatRules.clamp_yaw(rotation.y, _seat_yaw, _seat_yaw_limit)
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_head.rotation.x = clampf(_head.rotation.x - turn.y, -max_pitch, max_pitch)


## Devolve a altura da cabeça para o estado atual: ajoelhado, sentado ou em pé.
func _target_head_height() -> float:
	if is_knocked_down:
		return kneeling_head_height
	if is_seated:
		return seated_head_height
	return _standing_head_height


## Desconta o tempo da derrubada e libera o jogador quando ele acaba.
func _update_knockdown(delta: float) -> void:
	if not is_knocked_down:
		return
	_knockdown_left -= delta
	if _knockdown_left <= 0.0:
		is_knocked_down = false


## Devolve a velocidade de corrida com a tecla segura e sem bloqueio; senão, a de caminhada.
func _current_speed() -> float:
	if Input.is_action_pressed("sprint") and not _fall_damage.is_sprint_blocked():
		return sprint_speed
	return walk_speed


## Captura o mouse para o jogo ou o libera para os menus.
func _capture_mouse(captured: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


## Mata o jogador com a causa de queda.
func _on_fall_damage_fatal_fall() -> void:
	kill(CAUSE_FALL)


## Repassa o bloqueio da corrida para quem está fora do jogador.
func _on_fall_damage_sprint_blocked_changed(active: bool) -> void:
	sprint_blocked_changed.emit(active)
