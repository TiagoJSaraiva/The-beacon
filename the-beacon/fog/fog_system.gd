class_name FogSystem
extends Node
## Roda o nevoeiro da noite e avisa a intensidade a câmeras, barcos e Homem de Nevoeiro.

signal intensity_changed(intensity: float)
## O nevoeiro passou a cobrir (ou deixou de cobrir) a câmera do farol.
signal covers_lighthouse_camera_changed(covers: bool)

const EVENT_FOG := &"fog"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: FogState = FogState.new(FogConfig.new())

var _published_intensity: float = -1.0
var _published_covers: bool = false


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	state.tick(delta, rng)
	_publish()


func configure(config: FogConfig) -> void:
	state = FogState.new(config)
	_publish()


func register_events(events: EventDirector) -> void:
	events.register(EVENT_FOG, can_start, start)


func can_start() -> bool:
	return not state.is_active


func start() -> void:
	state.start(rng)


func clear() -> void:
	state.clear()
	_publish()


func to_dict() -> Dictionary:
	return state.to_dict()


func from_dict(data: Dictionary) -> void:
	state.from_dict(data)
	_publish()


func _publish() -> void:
	var covers: bool = state.covers_lighthouse_camera()
	if covers != _published_covers:
		_published_covers = covers
		covers_lighthouse_camera_changed.emit(covers)
	if is_equal_approx(state.intensity, _published_intensity):
		return
	_published_intensity = state.intensity
	intensity_changed.emit(state.intensity)
