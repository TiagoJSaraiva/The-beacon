class_name Flashlight
extends Node3D
## Lanterna na mão esquerda: liga e desliga e, segurando `check_battery`, mostra a carga
## numa barra no próprio corpo. A bateria nunca aparece na HUD (GDD 1.2.19). Com `follow`, fica na
## mão do corpo do jogador e aponta para onde ele olha; sem, fica na posição de repouso em relação
## ao pai.

signal toggled(lit: bool)
signal battery_depleted

@export var config: FlashlightConfig
## Posição de repouso em relação ao pai, usada sem `follow`.
@export var rest_position: Vector3 = Vector3(-0.28, -0.24, -0.42)
## Deslocamento do corpo da lanterna em relação à mão, nos eixos da câmera.
@export var hand_offset: Vector3 = Vector3.ZERO
## Posição e giro que deixam a barra de carga de frente para a câmera.
@export var inspect_position: Vector3 = Vector3(-0.08, -0.12, -0.3)
@export var inspect_yaw_degrees: float = -90.0
@export var pose_speed: float = 10.0

var input_enabled: bool = true
var battery: FlashlightBattery

var _lit: bool = false
var _hand: Node3D
var _view: Node3D
## 0 = na mão, 1 = na frente da câmera, inspecionando a bateria.
var _inspect_weight: float = 0.0

@onready var _light: SpotLight3D = %Light
@onready var _gauge: BatteryGauge = %BatteryGauge


## Põe a lanterna na posição de repouso e aplica a configuração. Sem `config`, usa os valores
## padrão.
func _ready() -> void:
	position = rest_position
	# O Game chama configure() com a dificuldade; o padrão serve para cenas de teste.
	if config == null:
		config = FlashlightConfig.new()
	configure(config)


## Lê as teclas, move a lanterna entre repouso e inspeção e, acesa, gasta a bateria. Zerada,
## apaga e emite `battery_depleted`.
func _process(delta: float) -> void:
	if input_enabled and Input.is_action_just_pressed("toggle_flashlight"):
		toggle()
	var inspecting: bool = input_enabled and Input.is_action_pressed("check_battery")
	_update_pose(inspecting, delta)
	if not _lit:
		return
	if not battery.drain(delta):
		_set_lit(false)
		battery_depleted.emit()
	_refresh_display()


## Reinicia a lanterna com a configuração da dificuldade (bateria cheia, desligada).
func configure(new_config: FlashlightConfig) -> void:
	config = new_config
	battery = FlashlightBattery.new(config.battery_seconds)
	_light.spot_range = config.beam_range
	_light.spot_angle = config.beam_half_angle_degrees
	_set_lit(false)
	_refresh_display()


## Apaga se estiver acesa; se estiver apagada, acende, desde que ainda haja carga.
func toggle() -> void:
	if _lit:
		_set_lit(false)
	elif not battery.is_empty():
		_set_lit(true)


## Diz se a lanterna está acesa.
func is_lit() -> bool:
	return _lit


## Aplica a carga que sobrou da noite anterior, limitada à capacidade, e deixa a lanterna
## apagada.
func set_battery_seconds(seconds: float) -> void:
	battery.remaining_seconds = clampf(seconds, 0.0, battery.capacity_seconds)
	_set_lit(false)
	_refresh_display()


## Diz se o ponto está dentro do cone aceso. Obstáculos são checados por quem pergunta.
func illuminates(point: Vector3) -> bool:
	if not _lit:
		return false
	return FlashlightCone.contains(
		_light.global_position,
		-_light.global_basis.z,
		point,
		config.beam_range,
		config.beam_half_angle_degrees
	)


## Acende ou apaga a luz e emite `toggled` só quando o estado muda.
func _set_lit(lit: bool) -> void:
	if _lit == lit:
		_light.visible = lit
		return
	_lit = lit
	_light.visible = lit
	toggled.emit(lit)


## Aproxima a posição e o giro da pose de inspeção ou da de repouso. Seguindo a mão, o repouso é
## o ponto da mão com a direção da câmera, e a inspeção, a frente da câmera.
func _update_pose(inspecting: bool, delta: float) -> void:
	var weight: float = clampf(pose_speed * delta, 0.0, 1.0)
	if _hand != null and _view != null:
		_inspect_weight = lerpf(_inspect_weight, 1.0 if inspecting else 0.0, weight)
		global_transform = _hand_rest_transform().interpolate_with(
			_inspect_transform(), _inspect_weight
		)
		return
	var target_position: Vector3 = inspect_position if inspecting else rest_position
	var target_yaw: float = deg_to_rad(inspect_yaw_degrees) if inspecting else 0.0
	position = position.lerp(target_position, weight)
	rotation.y = lerp_angle(rotation.y, target_yaw, weight)


## Passa a seguir a mão `hand` (um ponto do corpo do jogador) e a apontar para onde `view` (a
## câmera) aponta. Daí em diante a lanterna não depende do pai.
func follow(hand: Node3D, view: Node3D) -> void:
	_hand = hand
	_view = view
	top_level = true
	_inspect_weight = 0.0
	global_transform = _hand_rest_transform()


## Devolve a pose de repouso no mundo: na mão, com a direção da câmera.
func _hand_rest_transform() -> Transform3D:
	var view_basis: Basis = _view.global_basis
	return Transform3D(view_basis, _hand.global_position + view_basis * hand_offset)


## Devolve a pose de inspeção da bateria no mundo: na frente da câmera, com a barra de frente.
func _inspect_transform() -> Transform3D:
	var local := Transform3D(Basis(Vector3.UP, deg_to_rad(inspect_yaw_degrees)), inspect_position)
	return _view.global_transform * local


## Mostra a carga atual na barra da lanterna.
func _refresh_display() -> void:
	_gauge.show_ratio(battery.ratio())
