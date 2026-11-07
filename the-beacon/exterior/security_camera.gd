class_name SecurityCamera
extends Node3D
## Câmera de segurança externa (GDD 1.2.17). Renderiza num SubViewport próprio; o monitor
## no farol exibe a textura. O nevoeiro aparece pelos volumes do FogVisuals.

@export var target: Node3D
@export var resolution: Vector2i = Vector2i(320, 240)

@onready var _viewport: SubViewport = %Viewport
@onready var _camera: Camera3D = %Camera


## Aplica a resolução, mira o alvo e copia a pose para a câmera dentro do SubViewport.
func _ready() -> void:
	_viewport.size = resolution
	if target != null:
		look_at(target.global_position)
	# O SubViewport quebra a herança de transform: a câmera recebe a pose do marcador.
	_camera.global_transform = global_transform


## Devolve a imagem da câmera, para exibir num monitor.
func get_feed() -> ViewportTexture:
	return _viewport.get_texture()
