class_name Exterior
extends Node3D
## Ilha, mar, rota dos barcos, câmeras de segurança e pontos de chegada das ameaças.

@onready var sea_camera: SecurityCamera = %SeaCamera
@onready var lighthouse_camera: SecurityCamera = %LighthouseCamera
@onready var boat_path: Path3D = %BoatPath
@onready var _drowned_spawns: Node3D = %DrownedSpawns
@onready var _fog_man_spawn: Marker3D = %FogManSpawn


func set_fog_intensity(intensity: float) -> void:
	sea_camera.set_fog_intensity(intensity)
	lighthouse_camera.set_fog_intensity(intensity)


func drowned_spawn_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for child: Node in _drowned_spawns.get_children():
		var marker := child as Marker3D
		if marker != null:
			points.append(marker.global_position)
	return points


func fog_man_spawn_point() -> Vector3:
	return _fog_man_spawn.global_position
