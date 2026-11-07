class_name MachineHouse
extends Node3D
## Casa de máquinas, na cabine: gira o farol pela tubulação que sobe até o telhado. Quebra
## ao acaso e tem conserto. Na tubulação fica a câmara da lâmpada, onde ela é trocada.

signal broken_changed(broken: bool)
## O jogador terminou a troca da lâmpada na câmara.
signal lamp_replaced

@export var flywheel_speed_degrees: float = 220.0

var failure: FailureState = FailureState.new()

var _running: bool = false

@onready var _flywheel: Node3D = %Flywheel
@onready var _repair_point: Interactable = %RepairPoint
@onready var _replace_point: Interactable = %ReplacePoint
@onready var _broken_light: Light3D = %BrokenLight
@onready var _burned_light: Light3D = %BurnedLight
@onready var _hum: LoopingSound = %Hum
@onready var _alarm: LoopingSound = %Alarm


## Começa sem sinais de lâmpada queimada nem de quebra.
func _ready() -> void:
	show_lamp_burned(false)
	_refresh()


## Conta o intervalo entre quebras e gira o volante enquanto o farol opera.
func _process(delta: float) -> void:
	failure.tick(delta)
	if _running:
		_flywheel.rotate_z(deg_to_rad(flywheel_speed_degrees) * delta)


## Recria a casa de máquinas inteira e aplica o intervalo e as durações de conserto e troca.
func configure(repair_config: RepairConfig) -> void:
	failure = FailureState.new(repair_config.machine_breakdown_cooldown_seconds)
	_repair_point.hold_seconds = repair_config.machine_repair_seconds
	_replace_point.hold_seconds = repair_config.lamp_replace_seconds
	_refresh()


## Diz se a casa de máquinas está quebrada.
func is_broken() -> bool:
	return failure.is_broken


## Diz se ela está inteira e já passou do intervalo desde o último conserto.
func can_break_down() -> bool:
	return failure.can_break()


## Quebra a casa de máquinas, se puder quebrar agora: liga alarme e luz, libera o conserto e
## emite `broken_changed`.
func break_down() -> void:
	if not failure.can_break():
		return
	failure.break_down()
	_refresh()
	broken_changed.emit(true)


## Conserta a casa de máquinas, começa o intervalo até a próxima quebra e emite `broken_changed`.
func repair() -> void:
	if not failure.is_broken:
		return
	failure.repair()
	_refresh()
	broken_changed.emit(false)


## Faz o volante girar e a máquina zumbir enquanto o farol opera.
func show_running(running: bool) -> void:
	_running = running
	_hum.set_active(running)


## Com a lâmpada queimada, acende a luz da câmara e libera a troca.
func show_lamp_burned(burned: bool) -> void:
	_burned_light.visible = burned
	_replace_point.enabled = burned


## Mostra o estado de quebra: ponto de conserto, luz vermelha e alarme.
func _refresh() -> void:
	_repair_point.enabled = failure.is_broken
	_broken_light.visible = failure.is_broken
	_alarm.set_active(failure.is_broken)


## Conserta a casa de máquinas ao completar a barra.
func _on_repair_point_hold_completed() -> void:
	repair()


## Avisa que a troca da lâmpada terminou. O farol repassa o aviso à lâmpada.
func _on_replace_point_hold_completed() -> void:
	lamp_replaced.emit()
