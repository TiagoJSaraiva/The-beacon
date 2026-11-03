class_name Exterior
extends Node3D
## Ilha, mar, rota dos barcos, câmeras de segurança e pontos de chegada das ameaças.

## Panorama do mar: a da esquerda mira o lado +X da rota, que aparece à esquerda na tela.
@onready var sea_camera_left: SecurityCamera = %SeaCameraLeft
@onready var sea_camera_right: SecurityCamera = %SeaCameraRight
@onready var door_camera: SecurityCamera = %DoorCamera
@onready var boat_path: Path3D = %BoatPath
@onready var _drowned_spawns: Node3D = %DrownedSpawns
@onready var _fog_man_spawn: Marker3D = %FogManSpawn


func drowned_spawn_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for child: Node in _drowned_spawns.get_children():
		var marker := child as Marker3D
		if marker != null:
			points.append(marker.global_position)
	return points


func fog_man_spawn_point() -> Vector3:
	return _fog_man_spawn.global_position
