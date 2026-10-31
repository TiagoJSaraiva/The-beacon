class_name JerrycanDock
extends Node3D
## Ponto de devolução do galão, ao lado da reserva. O galão só sai da mão aqui (GDD 1.2.24).
## Guarda o estado do galão; o jogador só exibe o galão na mão.

signal carried_changed(carried: bool)

var jerrycan: JerrycanState = JerrycanState.new(PowerConfig.new().jerrycan_capacity)

@onready var _docked_mesh: Node3D = %DockedJerrycan


func _ready() -> void:
	_refresh()


func configure(power: PowerConfig) -> void:
	jerrycan = JerrycanState.new(power.jerrycan_capacity)
	_refresh()


func to_dict() -> Dictionary:
	return jerrycan.to_dict()


func from_dict(data: Dictionary) -> void:
	jerrycan.from_dict(data)
	_refresh()
	carried_changed.emit(jerrycan.is_carried)


func _refresh() -> void:
	_docked_mesh.visible = not jerrycan.is_carried


func _on_dock_point_interacted() -> void:
	jerrycan.is_carried = not jerrycan.is_carried
	_refresh()
	carried_changed.emit(jerrycan.is_carried)
