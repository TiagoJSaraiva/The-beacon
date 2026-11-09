class_name SecurityCamera
extends Node3D
## Câmera de segurança externa (GDD 1.2.17). Renderiza num SubViewport próprio; o monitor
## no farol exibe a textura. O nevoeiro aparece pelos volumes do FogVisuals.

@export var target: Node3D
@export var resolution: Vector2i = Vector2i(320, 240)
## Campo de visão vertical, em graus.
@export_range(1.0, 179.0, 0.1) var fov: float = 60.0
## Camadas de render que a câmera enxerga; as do mar deixam de fora o anel de nevoeiro em volta do
## farol.
@export_flags_3d_render var cull_mask: int = 0xFFFFF
## Câmera feita para vigiar a rota dos barcos: só nela o rádio ouve os barcos. A da porta
## também alcança o mar distante pelo enquadramento, mas não serve para isso.
@export var shows_boat_route: bool = false

@onready var _viewport: SubViewport = %Viewport
@onready var _camera: Camera3D = %Camera


## Aplica a resolução, o campo de visão e as camadas visíveis, mira o alvo e copia a pose para a
## câmera dentro do SubViewport.
func _ready() -> void:
	_viewport.size = resolution
	_camera.fov = fov
	_camera.cull_mask = cull_mask
	if target != null:
		look_at(target.global_position)
	# O SubViewport quebra a herança de transform: a câmera recebe a pose do marcador.
	_camera.global_transform = global_transform


## Devolve a câmera que renderiza a imagem, para saber o que está no enquadramento.
func get_camera() -> Camera3D:
	return _camera


## Devolve a imagem da câmera, para exibir num monitor.
func get_feed() -> ViewportTexture:
	return _viewport.get_texture()
