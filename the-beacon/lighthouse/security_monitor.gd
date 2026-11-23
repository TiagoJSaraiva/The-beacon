class_name SecurityMonitor
extends Node3D
## Monitor da mesa (GDD 1.2.17): mostra uma câmera por vez, e interagir passa ao próximo canal.
## Não depende do gerador: está sempre ligado. Avisa qual câmera precisa renderizar: só a do canal
## aberto, com o jogador no cômodo e a tela à vista (`MonitorChannels.live_channel`).

signal channel_changed(index: int)
## Mudou o canal cuja câmera precisa renderizar; `MonitorChannels.NO_CHANNEL` quando nenhuma.
signal live_channel_changed(index: int)

## Zona do cômodo do monitor, que detecta o jogador. Sem ela, o jogador conta como sempre presente.
@export var viewer_zone: Area3D

var channels: MonitorChannels = MonitorChannels.new(0)

var _feeds: Array[Texture2D] = []
var _material: StandardMaterial3D = StandardMaterial3D.new()

@onready var _screen: MeshInstance3D = %Screen


## Prepara a tela para mostrar a imagem sem depender da iluminação da cena e passa a acompanhar a
## presença do jogador na zona do cômodo.
func _ready() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_screen.material_override = _material
	if viewer_zone == null:
		channels.viewer_present = true
		return
	viewer_zone.body_entered.connect(_on_viewer_zone_changed.unbind(1))
	viewer_zone.body_exited.connect(_on_viewer_zone_changed.unbind(1))


## Recebe as imagens dos canais, na ordem, mostra a do primeiro e emite `live_channel_changed`.
func show_feeds(feeds: Array[Texture2D]) -> void:
	_feeds = feeds
	var previous: MonitorChannels = channels
	channels = MonitorChannels.new(feeds.size())
	channels.on_screen = previous.on_screen
	channels.viewer_present = previous.viewer_present
	_show_current()
	live_channel_changed.emit(channels.live_channel())


## Passa ao próximo canal e emite `channel_changed` e `live_channel_changed`.
func next_channel() -> void:
	channels.next()
	_show_current()
	channel_changed.emit(channels.current)
	live_channel_changed.emit(channels.live_channel())


## Guarda se a tela está à vista e emite `live_channel_changed`. O detector não vê paredes: a tela
## conta como à vista sempre que cabe no enquadramento de uma câmera.
func set_on_screen(on_screen: bool) -> void:
	channels.on_screen = on_screen
	live_channel_changed.emit(channels.live_channel())


## Atualiza a presença do jogador no cômodo e emite `live_channel_changed`.
func _on_viewer_zone_changed() -> void:
	channels.viewer_present = viewer_zone.has_overlapping_bodies()
	live_channel_changed.emit(channels.live_channel())


## Liga a câmera do canal aberto quando a tela entra no enquadramento.
func _on_screen_notifier_screen_entered() -> void:
	set_on_screen(true)


## Desliga as câmeras quando a tela sai do enquadramento.
func _on_screen_notifier_screen_exited() -> void:
	set_on_screen(false)


## Troca de canal ao interagir com o monitor.
func _on_switch_point_interacted() -> void:
	next_channel()


## Mostra na tela a imagem do canal aberto; sem canais, a tela fica vazia.
func _show_current() -> void:
	_material.albedo_texture = null if _feeds.is_empty() else _feeds[channels.current]
