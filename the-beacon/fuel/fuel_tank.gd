class_name FuelTank
extends Node3D
## Tanque de combustível no térreo (decisão 0017): reserva infinita. Alimenta o gerador
## principal pela mangueira, que estoura uma vez e não tem conserto. Tem o slot do galão.

signal hose_burst

## Depuração: começa a noite com a mangueira estourada, para testar o gerador de emergência
## e o galão antes de o nevoeiro estourá-la.
@export var debug_burst_on_start: bool = false

var is_hose_burst: bool = false

@onready var slot: JerrycanSlot = %JerrycanSlot
@onready var _hose: Node3D = %Hose
@onready var _burst: Node3D = %Burst
@onready var _burst_sound: AudioStreamPlayer3D = %BurstSound


func _ready() -> void:
	_refresh()
	if debug_burst_on_start:
		burst_hose.call_deferred(false)


func configure(power: PowerConfig) -> void:
	slot.configure(power)


## Estoura de vez. Sem som quando vem de uma noite anterior.
func burst_hose(with_sound: bool = true) -> void:
	if is_hose_burst:
		return
	is_hose_burst = true
	_refresh()
	if with_sound:
		_burst_sound.play()
	hose_burst.emit()


func _refresh() -> void:
	_hose.visible = not is_hose_burst
	_burst.visible = is_hose_burst
