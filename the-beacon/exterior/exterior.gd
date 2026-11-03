class_name Exterior
extends Node3D
## Ilha, mar, rota dos barcos, câmeras de segurança e o ponto de surgimento do Homem de
## Nevoeiro.

## Panorama do mar: a da esquerda mira o lado +X da rota, que aparece à esquerda na tela.
@onready var sea_camera_left: SecurityCamera = %SeaCameraLeft
@onready var sea_camera_right: SecurityCamera = %SeaCameraRight
@onready var door_camera: SecurityCamera = %DoorCamera
@onready var boat_path: Path3D = %BoatPath
@onready var _fog_man_spawn: Marker3D = %FogManSpawn


func fog_man_spawn_point() -> Vector3:
	return _fog_man_spawn.global_position
