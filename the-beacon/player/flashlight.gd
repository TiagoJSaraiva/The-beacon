class_name Flashlight
extends Node3D
## Lanterna na mão esquerda: liga e desliga (Z) e mostra a bateria no próprio corpo (X).
## A bateria nunca aparece na HUD (GDD 1.2.19).

signal toggled(lit: bool)
signal battery_depleted

@export var config: FlashlightConfig
@export var rest_position: Vector3 = Vector3(-0.28, -0.24, -0.42)
## Posição e giro que deixam o display de carga de frente para a câmera.
@export var inspect_position: Vector3 = Vector3(-0.08, -0.12, -0.3)
@export var inspect_yaw_degrees: float = -90.0
@export var pose_speed: float = 10.0

var input_enabled: bool = true
var battery: FlashlightBattery

var _lit: bool = false
var _shown_percent: int = -1

@onready var _light: SpotLight3D = %Light
@onready var _display: Label3D = %BatteryDisplay


func _ready() -> void:
	position = rest_position
	# O Game chama configure() com a dificuldade; o padrão serve para cenas de teste.
	if config == null:
		config = FlashlightConfig.new()
	configure(config)


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


func toggle() -> void:
	if _lit:
		_set_lit(false)
	elif not battery.is_empty():
		_set_lit(true)


func is_lit() -> bool:
	return _lit


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


func _set_lit(lit: bool) -> void:
	if _lit == lit:
		_light.visible = lit
		return
	_lit = lit
	_light.visible = lit
	toggled.emit(lit)


func _update_pose(inspecting: bool, delta: float) -> void:
	var weight: float = clampf(pose_speed * delta, 0.0, 1.0)
	var target_position: Vector3 = inspect_position if inspecting else rest_position
	var target_yaw: float = deg_to_rad(inspect_yaw_degrees) if inspecting else 0.0
	position = position.lerp(target_position, weight)
	rotation.y = lerp_angle(rotation.y, target_yaw, weight)


func _refresh_display() -> void:
	var percent: int = roundi(battery.ratio() * 100.0)
	if percent == _shown_percent:
		return
	_shown_percent = percent
	_display.text = "%d%%" % percent
