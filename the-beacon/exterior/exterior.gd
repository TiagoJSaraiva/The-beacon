class_name Exterior
extends Node3D
## Ilha, mar, rota dos barcos e câmeras de segurança.

## Panorama do mar: a da esquerda mira o lado +X da rota, que aparece à esquerda na tela.
@onready var sea_camera_left: SecurityCamera = %SeaCameraLeft
@onready var sea_camera_right: SecurityCamera = %SeaCameraRight
@onready var door_camera: SecurityCamera = %DoorCamera
@onready var boat_path: Path3D = %BoatPath


## Devolve as câmeras na ordem dos canais do monitor da mesa: porta, mar à esquerda, mar à direita.
func channel_cameras() -> Array[SecurityCamera]:
	return [door_camera, sea_camera_left, sea_camera_right]


## Devolve as imagens das câmeras na ordem dos canais.
func channel_feeds() -> Array[Texture2D]:
	var feeds: Array[Texture2D] = []
	for camera: SecurityCamera in channel_cameras():
		feeds.append(camera.get_feed())
	return feeds
