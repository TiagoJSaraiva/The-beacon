class_name LadderClimber
extends Area3D
## Detecta a zona de agarrar das escadas de mão (camada `ladders`) e calcula o movimento de quem
## está agarrado, com as regras de `LadderRules`. Com mais de uma zona, vale a última em que
## entrou.

@export var climb_speed: float = 2.0
## Fração do movimento horizontal que sobra agarrado, fora do chão.
@export_range(0.0, 1.0) var off_floor_horizontal_scale: float = 0.4
## Olhando para baixo além deste ângulo, a frente desce.
@export_range(0.0, 89.0) var descend_pitch_degrees: float = 30.0
## Quanto os pés passam do topo antes de parar de subir, para vencer a borda do piso.
@export var top_clearance: float = 0.1

var _ladders: Array[Ladder] = []


## Detecta só a camada das escadas e não é detectado por ninguém.
func _ready() -> void:
	collision_layer = 0
	collision_mask = CollisionLayers.LADDERS
	monitorable = false
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


## Diz se o corpo está na zona de agarrar de alguma escada.
func is_climbing() -> bool:
	return not _ladders.is_empty()


## Devolve a velocidade do corpo agarrado, em m/s. `wish_horizontal` é o movimento que o input
## pede no chão; `move_y`, o eixo frente/trás do input; `pitch`, a inclinação do olhar em
## radianos; `feet`, a posição global dos pés. Fora do chão, o horizontal encolhe e não se
## afasta da escada. Só vale com `is_climbing()`.
func climb_velocity(
	wish_horizontal: Vector3, move_y: float, pitch: float, on_floor: bool, feet: Vector3
) -> Vector3:
	var ladder: Ladder = _ladders.back()
	var away: Vector3 = ladder.away_direction()
	var horizontal: Vector3 = wish_horizontal
	if not on_floor:
		horizontal = LadderRules.without_away(horizontal * off_floor_horizontal_scale, away)
	# No chão, andar para longe da escada não pode puxar o corpo para cima.
	var leaving: bool = on_floor and horizontal.dot(away) > 0.0
	var direction: float = LadderRules.climb_direction(
		move_y, pitch, deg_to_rad(descend_pitch_degrees)
	)
	var vertical: float = LadderRules.vertical_speed(
		direction, climb_speed, feet.y, ladder.top_height() + top_clearance, leaving
	)
	return Vector3(horizontal.x, vertical, horizontal.z)


## Guarda a escada dona da zona em que o corpo entrou.
func _on_area_entered(area: Area3D) -> void:
	var ladder := area.owner as Ladder
	if ladder != null and not _ladders.has(ladder):
		_ladders.append(ladder)


## Esquece a escada dona da zona de que o corpo saiu.
func _on_area_exited(area: Area3D) -> void:
	var ladder := area.owner as Ladder
	if ladder != null:
		_ladders.erase(ladder)
