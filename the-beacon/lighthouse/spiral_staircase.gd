@tool
class_name SpiralStaircase
extends StaticBody3D
## Escada em caracol gerada por parâmetros, com vão no meio (GDD 1.2.20).
## A colisão é uma rampa em segmentos porque o CharacterBody3D não sobe degraus sozinho;
## o visual usa os mesmos segmentos. Os nós gerados não são salvos na cena.

# Sobreposição dos segmentos para não abrir frestas na borda externa da curva.
const SEGMENT_OVERLAP := 1.08
const RAIL_THICKNESS := 0.06

@export var inner_radius: float = 3.4:
	set(value):
		inner_radius = value
		_queue_build()
@export var outer_radius: float = 5.0:
	set(value):
		outer_radius = value
		_queue_build()
@export var start_height: float = 0.0:
	set(value):
		start_height = value
		_queue_build()
@export var end_height: float = 6.6:
	set(value):
		end_height = value
		_queue_build()
@export var turns: float = 1.0:
	set(value):
		turns = value
		_queue_build()
@export_range(0.0, 360.0) var start_angle_degrees: float = 0.0:
	set(value):
		start_angle_degrees = value
		_queue_build()
@export_range(4, 256) var segments: int = 48:
	set(value):
		segments = value
		_queue_build()
@export var thickness: float = 0.25:
	set(value):
		thickness = value
		_queue_build()
@export var material: Material:
	set(value):
		material = value
		_queue_build()
## Guarda-corpo na borda interna enquanto o degrau está abaixo desta altura. Sem ele, a
## lateral baixa do começo da escada vira atalho na navmesh que o corpo não consegue subir.
@export var low_rail_until_height: float = 1.0:
	set(value):
		low_rail_until_height = value
		_queue_build()
@export var rail_height: float = 0.9:
	set(value):
		rail_height = value
		_queue_build()

var _generated: Array[Node] = []
var _build_queued: bool = false


func _ready() -> void:
	collision_layer = CollisionLayers.WORLD
	_build()


## Ponto central do degrau no ângulo e altura da posição relativa (0 = base, 1 = topo).
func point_at(progress: float) -> Vector3:
	var angle: float = deg_to_rad(start_angle_degrees) + TAU * turns * progress
	var radius: float = (inner_radius + outer_radius) * 0.5
	var height: float = lerpf(start_height, end_height, progress)
	return Vector3(radius * cos(angle), height, radius * sin(angle))


func _queue_build() -> void:
	if not is_inside_tree() or _build_queued:
		return
	_build_queued = true
	_build.call_deferred()


func _build() -> void:
	_build_queued = false
	for node: Node in _generated:
		node.queue_free()
	_generated.clear()

	var length: float = point_at(0.0).distance_to(point_at(1.0 / segments)) * SEGMENT_OVERLAP
	var size := Vector3(length, thickness, outer_radius - inner_radius)
	var shape := BoxShape3D.new()
	shape.size = size
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material

	for i in segments:
		var start: Vector3 = point_at(float(i) / segments)
		var end: Vector3 = point_at(float(i + 1) / segments)
		var along: Vector3 = (end - start).normalized()
		var middle: Vector3 = (start + end) * 0.5
		var outward: Vector3 = Vector3(middle.x, 0.0, middle.z).normalized()
		var up: Vector3 = along.cross(outward)
		var segment_basis := Basis(along, up, along.cross(up))
		# A face de cima do segmento fica na linha da rampa.
		var segment_transform := Transform3D(segment_basis, middle - up * thickness * 0.5)
		_add_generated(_make_collision(shape, segment_transform))
		_add_generated(_make_mesh(mesh, segment_transform))
		if end.y < low_rail_until_height:
			_add_rail(middle, along, outward, length, end.y)


func _add_rail(
	middle: Vector3, along: Vector3, outward: Vector3, length: float, top: float
) -> void:
	var height: float = top + rail_height
	var size := Vector3(length, height, RAIL_THICKNESS)
	var shape := BoxShape3D.new()
	shape.size = size
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var flat_along: Vector3 = Vector3(along.x, 0.0, along.z).normalized()
	var rail_basis := Basis(flat_along, Vector3.UP, flat_along.cross(Vector3.UP))
	var center: Vector3 = (
		Vector3(middle.x, 0.0, middle.z)
		- outward * ((outer_radius - inner_radius) * 0.5 + RAIL_THICKNESS * 0.5)
	)
	var rail_transform := Transform3D(rail_basis, center + Vector3.UP * (height * 0.5))
	_add_generated(_make_collision(shape, rail_transform))
	_add_generated(_make_mesh(mesh, rail_transform))


func _make_collision(shape: Shape3D, segment_transform: Transform3D) -> CollisionShape3D:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.transform = segment_transform
	return collision


func _make_mesh(mesh: Mesh, segment_transform: Transform3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.transform = segment_transform
	return instance


func _add_generated(node: Node) -> void:
	add_child(node)
	_generated.append(node)
