@tool
class_name Ladder
extends StaticBody3D
## Escada de mão gerada por parâmetros. A origem fica no pé, no meio da largura; a escada sobe
## em Y local e se sobe pelo lado +Z local. A colisão é uma placa fina que acaba em `height`,
## para quem chega ao topo seguir em frente para o piso. A `ClimbZone` (camada `ladders`) marca
## onde o jogador se agarra; ela passa do topo e do plano da escada para cobrir a saída.
## Os nós gerados não são salvos na cena.

const PLATE_THICKNESS := 0.06

@export var height: float = 2.4:
	set(value):
		height = value
		_queue_build()
@export var width: float = 0.8:
	set(value):
		width = value
		_queue_build()
@export var rung_spacing: float = 0.3:
	set(value):
		rung_spacing = value
		_queue_build()
@export var rung_thickness: float = 0.04:
	set(value):
		rung_thickness = value
		_queue_build()
@export var rail_thickness: float = 0.05:
	set(value):
		rail_thickness = value
		_queue_build()
## Quanto as laterais passam do topo, como apoio para as mãos. Só visual.
@export var rail_extension: float = 0.9:
	set(value):
		rail_extension = value
		_queue_build()
## Profundidade da zona de agarrar no lado de quem sobe.
@export var climb_zone_depth: float = 0.7:
	set(value):
		climb_zone_depth = value
		_queue_build()
## Quanto a zona passa do topo e avança para trás da escada, cobrindo a saída para o piso.
@export var climb_zone_exit: float = 0.6:
	set(value):
		climb_zone_exit = value
		_queue_build()
@export var material: Material:
	set(value):
		material = value
		_queue_build()

var _generated: Array[Node] = []
var _build_queued: bool = false

@onready var _climb_zone: Area3D = %ClimbZone


## Coloca a escada na camada world, a zona na camada ladders e gera os nós.
func _ready() -> void:
	collision_layer = CollisionLayers.WORLD
	_climb_zone.collision_layer = CollisionLayers.LADDERS
	_build()


## Devolve a altura do topo da escada, em metros, no espaço global.
func top_height() -> float:
	return to_global(Vector3.UP * height).y


## Devolve a direção global que se afasta da escada, para o lado de quem sobe.
func away_direction() -> Vector3:
	return global_basis.z.normalized()


## Agenda uma única reconstrução adiada, para vários parâmetros mudados juntos. Fora da árvore,
## não faz nada.
func _queue_build() -> void:
	if not is_inside_tree() or _build_queued:
		return
	_build_queued = true
	_build.call_deferred()


## Apaga os nós gerados e recria a placa de colisão, as laterais, os degraus e a forma da zona
## de agarrar.
func _build() -> void:
	_build_queued = false
	for node: Node in _generated:
		node.queue_free()
	_generated.clear()

	var plate_size := Vector3(width, height, PLATE_THICKNESS)
	var plate := CollisionShape3D.new()
	var plate_shape := BoxShape3D.new()
	plate_shape.size = plate_size
	plate.shape = plate_shape
	plate.position = Vector3.UP * height * 0.5
	_add_generated(plate, self)

	var rail_height: float = height + rail_extension
	for side: float in [-1.0, 1.0]:
		var rail_center := Vector3(side * (width - rail_thickness) * 0.5, rail_height * 0.5, 0.0)
		_add_box(Vector3(rail_thickness, rail_height, rail_thickness), rail_center)
	var rung_height: float = rung_spacing
	while rung_height < height + rung_thickness:
		_add_box(Vector3(width, rung_thickness, rung_thickness), Vector3.UP * rung_height)
		rung_height += rung_spacing

	# A zona vai de trás da escada (saída no topo) até a frente de quem sobe.
	var zone_depth: float = climb_zone_depth + climb_zone_exit
	var zone_height: float = height + climb_zone_exit
	var zone := CollisionShape3D.new()
	var zone_shape := BoxShape3D.new()
	zone_shape.size = Vector3(width, zone_height, zone_depth)
	zone.shape = zone_shape
	zone.position = Vector3(0.0, zone_height * 0.5, (climb_zone_depth - climb_zone_exit) * 0.5)
	_add_generated(zone, _climb_zone)


## Cria uma peça visual em caixa com o tamanho e o centro dados.
func _add_box(size: Vector3, center: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = center
	_add_generated(instance, self)


## Adiciona o nó a `parent` e o registra para ser apagado na próxima reconstrução.
func _add_generated(node: Node, parent: Node) -> void:
	parent.add_child(node)
	_generated.append(node)
