class_name Exterior
extends Node3D
## Ilha, mar, rota dos barcos e câmeras de segurança.

## Panorama do mar: a da esquerda mira o lado +X da rota, que aparece à esquerda na tela.
@onready var sea_camera_left: SecurityCamera = %SeaCameraLeft
@onready var sea_camera_right: SecurityCamera = %SeaCameraRight
@onready var door_camera: SecurityCamera = %DoorCamera
@onready var boat_path: Path3D = %BoatPath
