class_name SecurityCamera
extends Node3D
## Câmera de segurança externa (GDD 1.2.17). Renderiza num SubViewport próprio; o monitor
## no farol exibe a textura. O nevoeiro aparece só na fog do Environment desta câmera.

@export var target: Node3D
@export var resolution: Vector2i = Vector2i(320, 240)
@export var max_fog_density: float = 0.2

@onready var _viewport: SubViewport = %Viewport
@onready var _camera: Camera3D = %Camera


func _ready() -> void:
	_viewport.size = resolution
	if target != null:
		look_at(target.global_position)
	# O SubViewport quebra a herança de transform: a câmera recebe a pose do marcador.
	_camera.global_transform = global_transform
	set_fog_intensity(0.0)


func get_feed() -> ViewportTexture:
	return _viewport.get_texture()


func set_fog_intensity(intensity: float) -> void:
	_camera.environment.fog_enabled = intensity > 0.0
	_camera.environment.fog_density = max_fog_density * intensity
