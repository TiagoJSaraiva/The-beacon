class_name JerrycanSlot
extends Node3D
## Slot do galão, no tanque (decisão 0017): com o galão devolvido, enche aos poucos e mostra
## o nível dele. Sem galão, o medidor fica zerado.

## Jogador com o galão na mão interagiu com o slot vazio.
signal return_requested

var _fill_seconds: float = PowerConfig.new().jerrycan_slot_fill_seconds
var _held: Jerrycan

@onready var _dock_point: Marker3D = %DockPoint
@onready var _return_point: Interactable = %ReturnPoint
@onready var _gauge_pivot: Node3D = %GaugePivot


func _process(delta: float) -> void:
	if _held != null:
		_held.state.refill(delta, _fill_seconds)
	_gauge_pivot.scale.y = maxf(_held.state.ratio() if _held != null else 0.0, 0.001)


func configure(power: PowerConfig) -> void:
	_fill_seconds = power.jerrycan_slot_fill_seconds


func dock_transform() -> Transform3D:
	return _dock_point.global_transform


func hold(jerrycan: Jerrycan) -> void:
	_held = jerrycan
	_return_point.enabled = false


func release() -> void:
	_held = null
	_return_point.enabled = true


func _on_return_point_interacted() -> void:
	return_requested.emit()
