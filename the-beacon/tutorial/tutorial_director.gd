class_name TutorialDirector
extends Node
## Tutorial do Easy (GDD 9.1): na primeira vez que cada situação acontece, pede um texto
## curto à HUD. Não pausa e não pode ser pulado; os sorteios seguem normais.
## Recebe os sistemas do Game em setup() e só escuta os sinais deles.

## Texto atual do tutorial; vazio esconde.
signal message_changed(text: String)

const STEP_START := &"start"
const STEP_FLASHLIGHT := &"flashlight"
const STEP_LOW_FUEL := &"low_fuel"
const STEP_JERRYCAN := &"jerrycan"
const STEP_LAMP_BURNED := &"lamp_burned"
const STEP_HOSE_BROKEN := &"hose_broken"
const STEP_GENERATOR_BROKEN := &"generator_broken"
const STEP_FOG := &"fog"
const STEP_BOAT := &"boat"
const STEP_DROWNED := &"drowned"
const STEP_DOOR_BROKEN := &"door_broken"
const STEP_FOG_MAN := &"fog_man"
## Passos que este diretor sabe disparar. Um passo do conteúdo fora daqui nunca aparece.
const KNOWN_STEPS: Array[StringName] = [
	STEP_START,
	STEP_FLASHLIGHT,
	STEP_LOW_FUEL,
	STEP_JERRYCAN,
	STEP_LAMP_BURNED,
	STEP_HOSE_BROKEN,
	STEP_GENERATOR_BROKEN,
	STEP_FOG,
	STEP_BOAT,
	STEP_DROWNED,
	STEP_DOOR_BROKEN,
	STEP_FOG_MAN,
]

@export var content: TutorialContent
## Abaixo desta fração de combustível no gerador, aparece o passo de reabastecer.
@export_range(0.0, 1.0) var low_fuel_ratio: float = 0.35

var tracker: TutorialTracker = TutorialTracker.new([])
var is_active: bool = false

var _generator: Generator
var _queue: Array[String] = []
var _message_time_left: float = 0.0


func _process(delta: float) -> void:
	if not is_active:
		return
	if _generator.state.fuel_ratio() < low_fuel_ratio:
		show_step(STEP_LOW_FUEL)
	if _message_time_left > 0.0:
		_message_time_left -= delta
		if _message_time_left <= 0.0:
			_show_next_message()


## Liga os gatilhos. Sem `enabled` (dificuldade sem tutorial), o diretor fica parado.
func setup(
	enabled: bool,
	night: NightDirector,
	lighthouse: Lighthouse,
	fog: FogSystem,
	boats: BoatDirector,
	drowned: DrownedDirector,
	fog_man: FogManDirector
) -> void:
	var ids: Array[StringName] = []
	if content != null:
		ids = content.step_ids()
	tracker = TutorialTracker.new(ids)
	is_active = enabled and content != null
	if not is_active:
		return
	_generator = lighthouse.generator
	night.night_started.connect(_on_night_started)
	lighthouse.jerrycan_carried_changed.connect(_show_when.bind(STEP_JERRYCAN))
	lighthouse.lamp.burned_changed.connect(_show_when.bind(STEP_LAMP_BURNED))
	lighthouse.reserve_tank.hose_broken_changed.connect(_show_when.bind(STEP_HOSE_BROKEN))
	lighthouse.generator.broken_changed.connect(_show_when.bind(STEP_GENERATOR_BROKEN))
	lighthouse.entrance_door.broken_changed.connect(_show_when.bind(STEP_DOOR_BROKEN))
	fog.intensity_changed.connect(_on_fog_intensity_changed)
	boats.boat_arrived.connect(show_step.bind(STEP_BOAT).unbind(2))
	drowned.drowned_appeared.connect(show_step.bind(STEP_DROWNED).unbind(1))
	fog_man.appeared.connect(show_step.bind(STEP_FOG_MAN))


## Mostra o passo se for a primeira vez; textos chegando juntos entram numa fila.
func show_step(step_id: StringName) -> void:
	if not is_active or not tracker.mark_shown(step_id):
		return
	_queue.append(content.text_for(step_id))
	if _message_time_left <= 0.0:
		_show_next_message()


func shown_ids() -> Array[StringName]:
	return tracker.shown_ids.duplicate()


func restore_shown(ids: Array[StringName]) -> void:
	tracker.restore(ids)


func _show_next_message() -> void:
	if _queue.is_empty():
		_message_time_left = 0.0
		message_changed.emit("")
		return
	_message_time_left = content.message_seconds
	message_changed.emit(_queue.pop_front())


func _show_when(active: bool, step_id: StringName) -> void:
	if active:
		show_step(step_id)


func _on_night_started(_night: int) -> void:
	show_step(STEP_START)
	show_step(STEP_FLASHLIGHT)


func _on_fog_intensity_changed(intensity: float) -> void:
	if intensity > 0.0:
		show_step(STEP_FOG)
