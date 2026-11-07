class_name LighthouseLamp
extends Node3D
## Cabeça do farol, acima do telhado: gira com o farol operando e mostra o feixe aceso
## (GDD 1.2.7). A lâmpada queima ao acaso; a troca é feita na câmara da lâmpada, na casa
## de máquinas, e as reposições são infinitas (GDD 1.2.18).

signal burned_changed(burned: bool)

@export var rotation_speed_degrees: float = 36.0

var failure: FailureState = FailureState.new()

var _turning: bool = false

@onready var _head: Node3D = %Head
@onready var _beam: Node3D = %Beam


## Começa com o feixe escondido.
func _ready() -> void:
	_beam.visible = false


## Conta o intervalo entre quebras e gira a cabeça enquanto o farol opera.
func _process(delta: float) -> void:
	failure.tick(delta)
	if _turning:
		_head.rotate_y(deg_to_rad(rotation_speed_degrees) * delta)


## Recria a lâmpada inteira, com o intervalo de quebra da dificuldade.
func configure(repair_config: RepairConfig) -> void:
	failure = FailureState.new(repair_config.lamp_burnout_cooldown_seconds)


## Faz a cabeça girar com o farol operando e mostra o feixe só quando aceso.
func show_beam(operational: bool, lit: bool) -> void:
	_turning = operational
	_beam.visible = lit


## Diz se a lâmpada está queimada.
func is_burned() -> bool:
	return failure.is_broken


## Diz se a lâmpada está inteira e já passou do intervalo desde a última troca.
func can_burn_out() -> bool:
	return failure.can_break()


## Queima a lâmpada, se puder quebrar agora, e emite `burned_changed`.
func burn_out() -> void:
	if not failure.can_break():
		return
	failure.break_down()
	burned_changed.emit(true)


## Troca a lâmpada queimada, começa o intervalo até a próxima quebra e emite `burned_changed`.
func replace() -> void:
	if not failure.is_broken:
		return
	failure.repair()
	burned_changed.emit(false)
