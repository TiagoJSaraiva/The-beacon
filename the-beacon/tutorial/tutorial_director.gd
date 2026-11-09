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
const STEP_HOSE_BURST := &"hose_burst"
const STEP_MACHINE_BROKEN := &"machine_broken"
const STEP_FOG := &"fog"
const STEP_FOG_NEAR := &"fog_near"
const STEP_FOG_BEAM := &"fog_beam"
const STEP_LATCH := &"latch"
const STEP_BOAT := &"boat"
const STEP_DROWNED_APPROACHING := &"drowned_approaching"
const STEP_DROWNED := &"drowned"
const STEP_FIGUREHEAD := &"figurehead"
## Passos que este diretor sabe disparar. Um passo do conteúdo fora daqui nunca aparece.
const KNOWN_STEPS: Array[StringName] = [
	STEP_START,
	STEP_FLASHLIGHT,
	STEP_LOW_FUEL,
	STEP_JERRYCAN,
	STEP_LAMP_BURNED,
	STEP_HOSE_BURST,
	STEP_MACHINE_BROKEN,
	STEP_FOG,
	STEP_FOG_NEAR,
	STEP_FOG_BEAM,
	STEP_LATCH,
	STEP_BOAT,
	STEP_DROWNED_APPROACHING,
	STEP_DROWNED,
	STEP_FIGUREHEAD,
]

@export var content: TutorialContent
## Abaixo desta fração de combustível no gerador de emergência, aparece o passo de
## reabastecer.
@export_range(0.0, 1.0) var low_fuel_ratio: float = 0.35

var tracker: TutorialTracker = TutorialTracker.new([])
var is_active: bool = false

var _generator: Generator
var _queue: Array[String] = []
var _message_time_left: float = 0.0


## Dispara o passo de pouco combustível e troca a mensagem quando o tempo dela acaba.
func _process(delta: float) -> void:
	if not is_active:
		return
	if _generator.state.fuel_ratio() < low_fuel_ratio:
		show_step(STEP_LOW_FUEL)
	if _message_time_left > 0.0:
		_message_time_left -= delta
		if _message_time_left <= 0.0:
			_show_next_message()


## Cria o controle dos passos e liga os gatilhos aos sinais dos sistemas. Sem `enabled`
## (dificuldade sem tutorial) ou sem conteúdo, o diretor fica parado.
func setup(
	enabled: bool,
	night: NightDirector,
	lighthouse: Lighthouse,
	fog: FogSystem,
	boats: BoatDirector,
	drowned: DrownedDirector,
	figurehead: FigureheadDirector
) -> void:
	var ids: Array[StringName] = []
	if content != null:
		ids = content.step_ids()
	tracker = TutorialTracker.new(ids)
	is_active = enabled and content != null
	if not is_active:
		return
	_generator = lighthouse.emergency_generator
	night.night_started.connect(_on_night_started)
	lighthouse.jerrycan_carried_changed.connect(_show_when.bind(STEP_JERRYCAN))
	lighthouse.lamp.burned_changed.connect(_show_when.bind(STEP_LAMP_BURNED))
	lighthouse.fuel_tank.hose_burst.connect(show_step.bind(STEP_HOSE_BURST))
	lighthouse.machine_house.broken_changed.connect(_show_when.bind(STEP_MACHINE_BROKEN))
	fog.stage_changed.connect(_on_fog_stage_changed)
	boats.calling_changed.connect(_show_when.bind(STEP_BOAT))
	drowned.approaching_changed.connect(_show_when.bind(STEP_DROWNED_APPROACHING))
	drowned.drowned_entered.connect(show_step.bind(STEP_DROWNED))
	figurehead.appeared.connect(show_step.bind(STEP_FIGUREHEAD))


## Mostra o passo se for a primeira vez; textos chegando juntos entram numa fila.
func show_step(step_id: StringName) -> void:
	if not is_active or not tracker.mark_shown(step_id):
		return
	_queue.append(content.text_for(step_id))
	if _message_time_left <= 0.0:
		_show_next_message()


## Devolve uma cópia dos passos já mostrados, para passar à noite seguinte.
func shown_ids() -> Array[StringName]:
	return tracker.shown_ids.duplicate()


## Retoma os passos mostrados em noites anteriores.
func restore_shown(ids: Array[StringName]) -> void:
	tracker.restore(ids)


## Mostra o próximo texto da fila por `message_seconds`; com a fila vazia, esconde o texto.
func _show_next_message() -> void:
	if _queue.is_empty():
		_message_time_left = 0.0
		message_changed.emit("")
		return
	_message_time_left = content.message_seconds
	message_changed.emit(_queue.pop_front())


## Mostra o passo quando o sinal ligado a ele avisa que a situação começou.
func _show_when(active: bool, step_id: StringName) -> void:
	if active:
		show_step(step_id)


## Mostra os passos de início e da lanterna.
func _on_night_started(_night: int) -> void:
	show_step(STEP_START)
	show_step(STEP_FLASHLIGHT)


## Mostra os passos do nevoeiro conforme o estágio.
func _on_fog_stage_changed(stage: FogStage.Stage) -> void:
	if stage != FogStage.Stage.NONE:
		show_step(STEP_FOG)
	if stage >= FogStage.Stage.NEAR:
		show_step(STEP_FOG_NEAR)
	if FogStage.blocks_beam(stage):
		show_step(STEP_FOG_BEAM)
	if stage >= FogStage.Stage.TRAPDOOR:
		show_step(STEP_LATCH)
