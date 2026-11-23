@tool
class_name Island
extends MeshInstance3D
## Chão da ilha do farol: malha em anéis em volta do centro, com a altura de `IslandShape`. Só
## visual (ninguém anda fora do farol), sem colisão. A malha gerada não é salva na cena.

## Distância do último anel ao centro, já no fundo do mar.
@export var outer_radius: float = 60.0:
	set(value):
		outer_radius = value
		_queue_build()
## Distância entre anéis vizinhos.
@export var ring_spacing: float = 0.75:
	set(value):
		ring_spacing = value
		_queue_build()
## Pontos em cada anel.
@export_range(16, 512) var segments: int = 160:
	set(value):
		segments = value
		_queue_build()
@export var noise_seed: int = 7:
	set(value):
		noise_seed = value
		_queue_build()

var _build_queued: bool = false


## Gera a malha.
func _ready() -> void:
	_build()


## Agenda uma única reconstrução adiada, para vários parâmetros mudados juntos. Fora da árvore,
## não faz nada.
func _queue_build() -> void:
	if not is_inside_tree() or _build_queued:
		return
	_build_queued = true
	_build.call_deferred()


## Troca a malha pela gerada com os parâmetros atuais.
func _build() -> void:
	_build_queued = false
	mesh = build_mesh(IslandShape.new(noise_seed))


## Devolve a malha do chão para o relevo dado: um ponto no centro e anéis de `segments` pontos a
## cada `ring_spacing` metros até `outer_radius`, com as faces viradas para cima.
func build_mesh(shape: IslandShape) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: int = ceili(outer_radius / ring_spacing)
	surface.add_vertex(Vector3(0.0, shape.height_at(0.0, 0.0), 0.0))
	for ring in range(1, rings + 1):
		var distance: float = minf(ring * ring_spacing, outer_radius)
		for step in segments:
			var angle: float = TAU * step / segments
			var height: float = shape.height_at(distance, angle)
			surface.add_vertex(Vector3(distance * cos(angle), height, distance * sin(angle)))
	for step in segments:
		_add_up_triangle(surface, 0, 1 + step, 1 + (step + 1) % segments)
	for ring in range(1, rings):
		var inner: int = 1 + (ring - 1) * segments
		var outer: int = 1 + ring * segments
		for step in segments:
			var next: int = (step + 1) % segments
			_add_up_triangle(surface, inner + step, outer + step, outer + next)
			_add_up_triangle(surface, inner + step, outer + next, inner + next)
	surface.generate_normals()
	return surface.commit()


## Acrescenta o triângulo pelos índices dados (centro ou anel de dentro primeiro, depois os pontos
## de fora em ângulo crescente), nessa ordem: assim a face da frente olha para +Y
## (`test/unit/island_shape_test.gd`).
func _add_up_triangle(surface: SurfaceTool, a: int, b: int, c: int) -> void:
	surface.add_index(a)
	surface.add_index(b)
	surface.add_index(c)
