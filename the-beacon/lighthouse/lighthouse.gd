class_name Lighthouse
extends Node3D
## Farol: agrupa os sistemas físicos e liga os sinais entre eles.
## O Game fala com o farol só por estes métodos e sinais.

signal jerrycan_carried_changed(carried: bool)
## Alavanca, energia, lâmpada e casa de máquinas em ordem: segura o nevoeiro.
signal beam_operational_changed(operational: bool)
## Operando e sem nevoeiro bloqueando: os barcos enxergam o feixe.
signal beam_lit_changed(lit: bool)

const EVENT_LAMP_BURNOUT := &"lamp_burnout"
const EVENT_MACHINE_BREAKDOWN := &"machine_breakdown"

var beam: BeamState = BeamState.new()

var _was_operational: bool = false
var _was_lit: bool = false

@onready var entrance_door: EntranceDoor = %EntranceDoor
@onready var trapdoor: Trapdoor = %Trapdoor
@onready var main_generator: Generator = %MainGenerator
@onready var emergency_generator: Generator = %EmergencyGenerator
@onready var fuel_tank: FuelTank = %FuelTank
@onready var jerrycan: Jerrycan = %Jerrycan
@onready var machine_house: MachineHouse = %MachineHouse
@onready var lamp: LighthouseLamp = %LighthouseLamp
@onready var beam_control: BeamControl = %BeamControl
@onready var radio: Radio = %Radio
@onready var chair: Chair = %Chair
@onready var _wall_clock: WallClock = %WallClock
@onready var _sea_monitor_left: SecurityMonitor = %SeaMonitorLeft
@onready var _sea_monitor_right: SecurityMonitor = %SeaMonitorRight
@onready var _door_monitor: SecurityMonitor = %DoorMonitor
@onready var _door_inside: Marker3D = %DoorInside
@onready var _rest_spot: Marker3D = %RestSpot
@onready var _trapdoor_below: Marker3D = %TrapdoorBelow


## Liga os sinais internos, assenta o galão no slot e calcula o estado inicial do farol.
func _ready() -> void:
	fuel_tank.hose_burst.connect(_on_fuel_tank_hose_burst)
	fuel_tank.slot.return_requested.connect(_on_jerrycan_slot_return_requested)
	jerrycan.pick_up_requested.connect(_on_jerrycan_pick_up_requested)
	emergency_generator.refuel_requested.connect(_on_emergency_generator_refuel_requested)
	main_generator.power_changed.connect(_refresh_beam.unbind(1))
	emergency_generator.power_changed.connect(_refresh_beam.unbind(1))
	beam_control.switched.connect(_refresh_beam.unbind(1))
	machine_house.broken_changed.connect(_refresh_beam.unbind(1))
	machine_house.lamp_replaced.connect(lamp.replace)
	lamp.burned_changed.connect(_on_lamp_burned_changed)
	_dock_jerrycan()
	_refresh_beam()


## Repassa aos sistemas do farol os valores da dificuldade.
func configure(difficulty: DifficultyConfig) -> void:
	main_generator.configure(difficulty.power)
	emergency_generator.configure(difficulty.power)
	fuel_tank.configure(difficulty.power)
	jerrycan.configure(difficulty.power)
	lamp.configure(difficulty.repair)
	machine_house.configure(difficulty.repair)
	trapdoor.configure(difficulty.trapdoor)
	_refresh_beam()


## Registra as falhas sorteáveis do farol (GDD 1.2.25).
func register_events(events: EventDirector) -> void:
	events.register(EVENT_LAMP_BURNOUT, lamp.can_burn_out, lamp.burn_out)
	events.register(EVENT_MACHINE_BREAKDOWN, machine_house.can_break_down, machine_house.break_down)


## Estoura a mangueira de vez: o gerador principal para e o de emergência assume
## (decisão 0017). Sem som quando vem de uma noite anterior.
func burst_hose(with_sound: bool = true) -> void:
	fuel_tank.burst_hose(with_sound)


## Diz se a mangueira já estourou.
func is_hose_burst() -> bool:
	return fuel_tank.is_hose_burst


## Solta o galão que está na mão em `at`, com a velocidade do arremesso.
func drop_jerrycan(at: Vector3, throw_velocity: Vector3) -> void:
	if jerrycan.place != Jerrycan.Place.HAND:
		return
	jerrycan.drop(at, throw_velocity)
	jerrycan_carried_changed.emit(false)


## Devolve os pontos onde o Afogado age dentro do farol.
func drowned_targets() -> Dictionary[DrownedBrain.Target, Vector3]:
	return {
		DrownedBrain.Target.TRAPDOOR_BELOW: _trapdoor_below.global_position,
		DrownedBrain.Target.REST_SPOT: _rest_spot.global_position,
	}


## Devolve o ponto onde o Afogado aparece depois de arrombar a porta.
func drowned_entry_point() -> Vector3:
	return _door_inside.global_position


## Liga as imagens das câmeras aos três monitores da mesa.
func show_camera_feeds(sea_left: Texture2D, sea_right: Texture2D, door: Texture2D) -> void:
	_sea_monitor_left.show_feed(sea_left)
	_sea_monitor_right.show_feed(sea_right)
	_door_monitor.show_feed(door)


## Aplica o estágio do nevoeiro: perto do farol, bloqueia o feixe; ao entrar pela primeira vez,
## estoura a mangueira (decisão 0017); no alçapão, desliga o trinco.
func set_fog_stage(stage: FogStage.Stage) -> void:
	beam.fog_blocking = FogStage.blocks_beam(stage)
	if FogStage.is_inside(stage):
		burst_hose()
	trapdoor.set_fog_present(stage >= FogStage.Stage.TRAPDOOR)
	_refresh_beam()


## Mostra o horário no relógio de parede.
func show_time(text: String) -> void:
	_wall_clock.show_time(text)


## Recalcula o farol a cada mudança de alavanca, energia, lâmpada, casa de máquinas ou
## nevoeiro.
func _refresh_beam() -> void:
	beam.switch_on = beam_control.is_on
	beam.powered = main_generator.is_running() or emergency_generator.is_running()
	beam.lamp_burned = lamp.is_burned()
	beam.machine_broken = machine_house.is_broken()
	# O de emergência só gasta quando é a fonte ativa e o farol está ligado.
	emergency_generator.set_in_use(beam.switch_on and not main_generator.is_running())
	lamp.show_beam(beam.is_operational(), beam.is_lit())
	machine_house.show_running(beam.is_operational())
	beam_control.show_status(beam.is_lit())
	var operational: bool = beam.is_operational()
	if operational != _was_operational:
		_was_operational = operational
		beam_operational_changed.emit(operational)
	var lit: bool = beam.is_lit()
	if lit != _was_lit:
		_was_lit = lit
		beam_lit_changed.emit(lit)


## Assenta o galão no slot e passa a enchê-lo.
func _dock_jerrycan() -> void:
	jerrycan.dock(fuel_tank.slot.dock_transform())
	fuel_tank.slot.hold(jerrycan)


## Para de vez o gerador principal quando a mangueira estoura.
func _on_fuel_tank_hose_burst() -> void:
	main_generator.set_hose_intact(false)


## Passa o galão para a mão, do slot ou do chão, e avisa que ele está sendo carregado.
func _on_jerrycan_pick_up_requested() -> void:
	if jerrycan.place == Jerrycan.Place.SLOT:
		fuel_tank.slot.release()
	jerrycan.take_in_hand()
	jerrycan_carried_changed.emit(true)


## Devolve ao slot o galão que está na mão e avisa que as mãos ficaram livres.
func _on_jerrycan_slot_return_requested() -> void:
	if jerrycan.place != Jerrycan.Place.HAND:
		return
	_dock_jerrycan()
	jerrycan_carried_changed.emit(false)


## Despeja o galão no gerador de emergência. O que não couber fica no galão.
func _on_emergency_generator_refuel_requested() -> void:
	jerrycan.state.pour_into(emergency_generator.state)


## Mostra a lâmpada queimada na casa de máquinas e recalcula o farol.
func _on_lamp_burned_changed(burned: bool) -> void:
	machine_house.show_lamp_burned(burned)
	_refresh_beam()
