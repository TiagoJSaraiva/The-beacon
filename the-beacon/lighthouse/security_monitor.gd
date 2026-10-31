class_name SecurityMonitor
extends Node3D
## Monitor fixo de uma câmera (GDD 1.2.17). Não depende do gerador: está sempre ligado.

@onready var _screen: MeshInstance3D = %Screen


func show_feed(feed: Texture2D) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = feed
	_screen.material_override = material
