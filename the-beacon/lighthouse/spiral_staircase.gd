@tool
class_name SpiralStaircase
extends StaticBody3D
## Escada em caracol gerada por parâmetros, com vão no meio (GDD 1.2.20).
## A colisão é uma rampa invisível em segmentos, porque o CharacterBody3D não sobe degraus sozinho.
## O visual são degraus soltos de chapa, presos na parede por uma mão-francesa cada, com a face de
## cima na altura da rampa no meio do degrau (divisão em `SpiralStepLayout`). Os nós gerados não
## são salvos na cena.

# Sobreposição dos segmentos para não abrir frestas na borda externa da curva.
const SEGMENT_OVERLAP := 1.08
# Faces de um sólido de 8 cantos, de 4 em 4 índices: 0–3 e 4–7 são o mesmo contorno, um em cada
# ponta.
const SOLID_FACES: Array[int] = [
	0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 5, 4, 1, 2, 6, 5, 2, 3, 7, 6, 3, 0, 4, 7
]
const FACE_CORNERS := 4

@export var inner_radius: float = 3.4:
	set(value):
		inner_radius = value
		_queue_build()
@export var outer_radius: float = 5.0:
	set(value):
		outer_radius = value
		_queue_build()
## Quanto os dois raios encolhem da base ao topo, para acompanhar uma parede inclinada.
@export var radius_shrink: float = 0.0:
	set(value):
		radius_shrink = value
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
## Espessura da rampa de colisão.
@export var thickness: float = 0.25:
	set(value):
		thickness = value
		_queue_build()
## Material dos degraus e das mãos-francesas.
@export var material: Material:
	set(value):
		material = value
		_queue_build()
## Altura aproximada de cada degrau; a quantidade sai da altura total.
@export var step_rise: float = 0.16:
	set(value):
		step_rise = value
		_queue_build()
## Fração da fatia de cada degrau ocupada pela chapa; o resto é o vão até o próximo.
@export_range(0.1, 1.0) var step_fill: float = 0.7:
	set(value):
		step_fill = value
		_queue_build()
@export var step_thickness: float = 0.05:
	set(value):
		step_thickness = value
		_queue_build()
## Quanto abaixo da chapa a mão-francesa encosta na parede.
@export var brace_drop: float = 0.35:
	set(value):
		brace_drop = value
		_queue_build()
@export var brace_width: float = 0.04:
	set(value):
		brace_width = value
		_queue_build()

var _generated: Array[Node] = []
var _build_queued: bool = false


## Coloca a escada na camada world e gera os nós dela.
func _ready() -> void:
	collision_layer = CollisionLayers.WORLD
	_build()


## Devolve o ponto central do degrau na posição relativa `progress` (0 = base, 1 = topo).
func point_at(progress: float) -> Vector3:
	var angle: float = deg_to_rad(start_angle_degrees) + TAU * turns * progress
	var radius: float = (inner_radius + outer_radius) * 0.5 - radius_shrink * progress
	var height: float = lerpf(start_height, end_height, progress)
	return Vector3(radius * cos(angle), height, radius * sin(angle))


## Agenda uma única reconstrução adiada, para vários parâmetros mudados juntos. Fora da árvore,
## não faz nada.
func _queue_build() -> void:
	if not is_inside_tree() or _build_queued:
		return
	_build_queued = true
	_build.call_deferred()


## Apaga os nós gerados e recria os segmentos da rampa de colisão e a malha dos degraus.
func _build() -> void:
	_build_queued = false
	for node: Node in _generated:
		node.queue_free()
	_generated.clear()

	var length: float = point_at(0.0).distance_to(point_at(1.0 / segments)) * SEGMENT_OVERLAP
	var size := Vector3(length, thickness, outer_radius - inner_radius)
	var shape := BoxShape3D.new()
	shape.size = size

	for i in segments:
		var start: Vector3 = point_at(float(i) / segments)
		var end: Vector3 = point_at(float(i + 1) / segments)
		var along: Vector3 = (end - start).normalized()
		var middle: Vector3 = (start + end) * 0.5
		var outward: Vector3 = Vector3(middle.x, 0.0, middle.z).normalized()
		# Com a escada encolhendo, `along` não é perpendicular a `outward`.
		var up: Vector3 = along.cross(outward).normalized()
		var segment_basis := Basis(along, up, along.cross(up))
		# A face de cima do segmento fica na linha da rampa.
		var segment_transform := Transform3D(segment_basis, middle - up * thickness * 0.5)
		_add_generated(_make_collision(shape, segment_transform))
	var steps := MeshInstance3D.new()
	steps.mesh = _build_steps_mesh()
	_add_generated(steps)


## Devolve a malha de todos os degraus e mãos-francesas, numa superfície só.
func _build_steps_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count: int = SpiralStepLayout.step_count(end_height - start_height, step_rise)
	for i in count:
		var span: Vector2 = SpiralStepLayout.step_range(i, count, step_fill)
		var center: float = SpiralStepLayout.step_center(i, count)
		var top: float = point_at(center).y
		_add_solid(surface, _step_corners(span.x, span.y, top))
		_add_solid(surface, _brace_corners(center, top))
	surface.set_material(material)
	return surface.commit()


## Devolve os 8 cantos da chapa em cunha entre os progressos `from` e `to`, com a face de cima em
## `top`: o contorno de baixo (dentro e fora no início, fora e dentro no fim) e o mesmo em cima.
func _step_corners(from: float, to: float, top: float) -> PackedVector3Array:
	var corners := PackedVector3Array()
	for height: float in [top - step_thickness, top]:
		corners.append(_rim_point(from, true, height))
		corners.append(_rim_point(from, false, height))
		corners.append(_rim_point(to, false, height))
		corners.append(_rim_point(to, true, height))
	return corners


## Devolve os 8 cantos da mão-francesa do degrau no progresso `progress`: uma barra quadrada que
## sai da parede, `brace_drop` abaixo da chapa, e chega ao meio da chapa por baixo.
func _brace_corners(progress: float, top: float) -> PackedVector3Array:
	var underside: float = top - step_thickness
	var wall_end: Vector3 = _rim_point(progress, false, underside - brace_drop)
	var middle: Vector3 = (
		(_rim_point(progress, true, underside) + _rim_point(progress, false, underside)) * 0.5
	)
	var along: Vector3 = (middle - wall_end).normalized()
	var side: Vector3 = along.cross(Vector3.UP).normalized() * brace_width * 0.5
	var lift: Vector3 = side.cross(along).normalized() * brace_width * 0.5
	var corners := PackedVector3Array()
	for end: Vector3 in [wall_end, middle - lift]:
		corners.append(end - side - lift)
		corners.append(end + side - lift)
		corners.append(end + side + lift)
		corners.append(end - side + lift)
	return corners


## Devolve o ponto da borda interna (`inner`) ou externa da escada no progresso `progress`, na
## altura `height`.
func _rim_point(progress: float, inner: bool, height: float) -> Vector3:
	var angle: float = deg_to_rad(start_angle_degrees) + TAU * turns * progress
	var radius: float = (inner_radius if inner else outer_radius) - radius_shrink * progress
	return Vector3(radius * cos(angle), height, radius * sin(angle))


## Acrescenta à superfície as seis faces do sólido de 8 cantos (ver `SOLID_FACES`), com normais
## planas viradas para fora.
func _add_solid(surface: SurfaceTool, corners: PackedVector3Array) -> void:
	var center := Vector3.ZERO
	for corner: Vector3 in corners:
		center += corner / corners.size()
	for first: int in range(0, SOLID_FACES.size(), FACE_CORNERS):
		var a: Vector3 = corners[SOLID_FACES[first]]
		var b: Vector3 = corners[SOLID_FACES[first + 1]]
		var c: Vector3 = corners[SOLID_FACES[first + 2]]
		var d: Vector3 = corners[SOLID_FACES[first + 3]]
		var outward: Vector3 = (a + b + c + d) * 0.25 - center
		_add_triangle(surface, [a, b, c], outward)
		_add_triangle(surface, [a, c, d], outward)


## Acrescenta o triângulo `points` virado para `outward`, invertendo a ordem dos vértices se
## preciso, com a normal plana.
func _add_triangle(surface: SurfaceTool, points: Array[Vector3], outward: Vector3) -> void:
	# Face da frente no Godot: a normal do `Plane` pelos três pontos aponta para dentro.
	var normal: Vector3 = Plane(points[0], points[1], points[2]).normal
	if normal.dot(outward) > 0.0:
		points.reverse()
	else:
		normal = -normal
	for point: Vector3 in points:
		surface.set_normal(normal)
		surface.add_vertex(point)


## Devolve um nó de colisão com a forma e a transformação dadas.
func _make_collision(shape: Shape3D, segment_transform: Transform3D) -> CollisionShape3D:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.transform = segment_transform
	return collision


## Adiciona o nó à escada e o registra para ser apagado na próxima reconstrução.
func _add_generated(node: Node) -> void:
	add_child(node)
	_generated.append(node)
