class_name Lighthouse
extends Node3D
## Farol: agrupa os sistemas físicos e liga os sinais entre eles.
## O Game fala com o farol só por estes métodos e sinais.

signal jerrycan_carried_changed(carried: bool)
signal beam_active_changed(active: bool)

const EVENT_LAMP_BURNOUT := &"lamp_burnout"
const EVENT_HOSE_RUPTURE := &"hose_rupture"
const EVENT_GENERATOR_BREAKDOWN := &"generator_breakdown"

@onready var entrance_door: EntranceDoor = %EntranceDoor
@onready var trapdoor: Trapdoor = %Trapdoor
@onready var generator: Generator = %Generator
@onready var reserve_tank: ReserveTank = %ReserveTank
@onready var jerrycan_dock: JerrycanDock = %JerrycanDock
@onready var lamp: LighthouseLamp = %LighthouseLamp
@onready var beam_control: BeamControl = %BeamControl
@onready var radio: Radio = %Radio
@onready var _wall_clock: WallClock = %WallClock
@onready var _sea_monitor: SecurityMonitor = %SeaMonitor
@onready var _lighthouse_monitor: SecurityMonitor = %LighthouseMonitor
@onready var _door_outside: Marker3D = %DoorOutside
@onready var _hose_spot: Marker3D = %HoseSpot
@onready var _generator_spot: Marker3D = %GeneratorSpot
@onready var _trapdoor_below: Marker3D = %TrapdoorBelow


func _ready() -> void:
	reserve_tank.fill_requested.connect(_on_reserve_tank_fill_requested)
	generator.refuel_requested.connect(_on_generator_refuel_requested)
	jerrycan_dock.carried_changed.connect(jerrycan_carried_changed.emit)
	beam_control.switched.connect(_on_beam_control_switched)
	lamp.beam_active_changed.connect(_on_lamp_beam_active_changed)


func configure(difficulty: DifficultyConfig) -> void:
	entrance_door.configure(difficulty.repair)
	generator.configure(difficulty.power, difficulty.repair)
	reserve_tank.configure(difficulty.power, difficulty.repair)
	jerrycan_dock.configure(difficulty.power)
	lamp.configure(difficulty.repair)
	trapdoor.configure(difficulty.trapdoor)


## Registra as falhas sorteáveis do farol (GDD 1.2.25).
func register_events(events: EventDirector) -> void:
	events.register(EVENT_LAMP_BURNOUT, lamp.can_burn_out, lamp.burn_out)
	events.register(EVENT_HOSE_RUPTURE, reserve_tank.can_break_hose, reserve_tank.break_hose)
	events.register(EVENT_GENERATOR_BREAKDOWN, generator.can_break_down, generator.break_down)


## Pontos onde os Afogados agem (GDD 1.2.10). A saída é definida por quem os cria.
func drowned_targets() -> Dictionary[DrownedBrain.Target, Vector3]:
	return {
		DrownedBrain.Target.DOOR_OUTSIDE: _door_outside.global_position,
		DrownedBrain.Target.HOSE: _hose_spot.global_position,
		DrownedBrain.Target.GENERATOR: _generator_spot.global_position,
		DrownedBrain.Target.TRAPDOOR_BELOW: _trapdoor_below.global_position,
	}


func show_camera_feeds(sea_feed: Texture2D, lighthouse_feed: Texture2D) -> void:
	_sea_monitor.show_feed(sea_feed)
	_lighthouse_monitor.show_feed(lighthouse_feed)


func show_time(text: String) -> void:
	_wall_clock.show_time(text)


func _on_reserve_tank_fill_requested() -> void:
	jerrycan_dock.jerrycan.fill_from(reserve_tank.state)


func _on_generator_refuel_requested() -> void:
	jerrycan_dock.jerrycan.pour_into(generator.state)


func _on_beam_control_switched(on: bool) -> void:
	lamp.set_switch_on(on)
	beam_control.show_status(lamp.is_active())


func _on_lamp_beam_active_changed(active: bool) -> void:
	generator.set_beam_load(active)
	beam_control.show_status(active)
	beam_active_changed.emit(active)
