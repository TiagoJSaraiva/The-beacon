class_name WallClock
extends Node3D
## Relógio digital fixo na parede (GDD 1.1). Funciona sem energia (decisão 0017, provisório).
## Fora da vista do jogador mostra o horário do jogo; enquanto ele o vê, o visor corre em tempo
## real e só alcança o jogo quando o olhar sai (`ClockDisplayRules`).

## Metade do tamanho da caixa do relógio (x, y), em metros: os pontos testados para saber se ele
## está à vista.
const CASE_HALF_SIZE := Vector2(0.3, 0.125)
## Quanto antes do visor o raio de oclusão para, para não bater na parede em que ele está colado.
const OCCLUSION_MARGIN := 0.05

## Segundos reais por minuto do visor enquanto o jogador o vê.
@export var seconds_per_viewed_minute: float = 60.0

var _rules: ClockDisplayRules
var _in_view: bool = false

@onready var _display: Label3D = %Display


## Cria a regra com o ritmo do visor visto e parte do horário escrito na cena.
func _ready() -> void:
	_rules = ClockDisplayRules.new(seconds_per_viewed_minute)
	_rules.set_game_time(_display.text)


## Avança o visor e o escreve só quando o texto muda.
func _process(delta: float) -> void:
	_refresh(delta)


## Confere se o relógio está à vista, o que depende do espaço físico (paredes no caminho).
func _physics_process(_delta: float) -> void:
	_in_view = _is_in_view()


## Guarda o horário do jogo, que o visor segue enquanto o relógio está fora da vista.
func show_time(text: String) -> void:
	_rules.set_game_time(text)
	_refresh(0.0)


## Escreve no visor o horário que a regra manda mostrar agora.
func _refresh(delta: float) -> void:
	var text: String = _rules.advance(delta, _in_view)
	if text != _display.text:
		_display.text = text


## Diz se algum ponto do relógio está dentro do campo de visão da câmera ativa e sem parede entre
## os dois.
func _is_in_view() -> bool:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return false
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var corners: Array[Vector2] = [
		Vector2.ZERO,
		Vector2(CASE_HALF_SIZE.x, CASE_HALF_SIZE.y),
		Vector2(-CASE_HALF_SIZE.x, CASE_HALF_SIZE.y),
		Vector2(CASE_HALF_SIZE.x, -CASE_HALF_SIZE.y),
		Vector2(-CASE_HALF_SIZE.x, -CASE_HALF_SIZE.y),
	]
	for corner: Vector2 in corners:
		var point: Vector3 = _display.global_transform * Vector3(corner.x, corner.y, 0.0)
		if camera.is_position_behind(point) or not camera.is_position_in_frustum(point):
			continue
		var from: Vector3 = camera.global_position
		var to: Vector3 = point - from.direction_to(point) * OCCLUSION_MARGIN
		var query := PhysicsRayQueryParameters3D.create(from, to, CollisionLayers.WORLD)
		if space.intersect_ray(query).is_empty():
			return true
	return false
