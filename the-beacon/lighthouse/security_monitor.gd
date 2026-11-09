class_name SecurityMonitor
extends Node3D
## Monitor da mesa (GDD 1.2.17): mostra uma câmera por vez, e interagir passa ao próximo canal.
## Não depende do gerador: está sempre ligado.

signal channel_changed(index: int)

var channels: MonitorChannels = MonitorChannels.new(0)

var _feeds: Array[Texture2D] = []
var _material: StandardMaterial3D = StandardMaterial3D.new()

@onready var _screen: MeshInstance3D = %Screen


## Prepara a tela para mostrar a imagem sem depender da iluminação da cena.
func _ready() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_screen.material_override = _material


## Recebe as imagens dos canais, na ordem, e mostra a do primeiro.
func show_feeds(feeds: Array[Texture2D]) -> void:
	_feeds = feeds
	channels = MonitorChannels.new(feeds.size())
	_show_current()


## Passa ao próximo canal e emite `channel_changed`.
func _on_switch_point_interacted() -> void:
	channels.next()
	_show_current()
	channel_changed.emit(channels.current)


## Mostra na tela a imagem do canal aberto; sem canais, a tela fica vazia.
func _show_current() -> void:
	_material.albedo_texture = null if _feeds.is_empty() else _feeds[channels.current]
