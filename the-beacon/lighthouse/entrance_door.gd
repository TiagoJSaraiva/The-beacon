class_name EntranceDoor
extends Node3D
## Porta do térreo: primeira barreira contra os Afogados (GDD 1.2.11).
## Quebrada, deixa os Afogados entrarem e soma ameaça; o conserto é segurar E.
## O jogador nunca sai: uma parede invisível só para ele fica no vão.

signal broken_changed(broken: bool)

var is_broken: bool = false

@onready var _panel: Node3D = %Panel
@onready var _panel_collision: CollisionShape3D = %PanelCollision
@onready var _broken_panel: Node3D = %BrokenPanel
@onready var _repair_point: Interactable = %RepairPoint


func _ready() -> void:
	_apply_state()


func configure(config: RepairConfig) -> void:
	_repair_point.hold_seconds = config.door_repair_seconds


func break_door() -> void:
	_set_broken(true)


func repair() -> void:
	_set_broken(false)


func to_dict() -> Dictionary:
	return {"is_broken": is_broken}


func from_dict(data: Dictionary) -> void:
	is_broken = data.get("is_broken", false)
	_apply_state()


func _set_broken(broken: bool) -> void:
	if is_broken == broken:
		return
	is_broken = broken
	_apply_state()
	broken_changed.emit(is_broken)


func _apply_state() -> void:
	_panel.visible = not is_broken
	_panel_collision.set_deferred("disabled", is_broken)
	_broken_panel.visible = is_broken
	_repair_point.enabled = is_broken


func _on_repair_point_hold_completed() -> void:
	repair()
