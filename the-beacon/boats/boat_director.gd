class_name BoatDirector
extends Node
## Faz os barcos cruzarem o mar quando o evento `boat` dispara (até
## `max_simultaneous_boats` ao mesmo tempo) e decide se passam, afundam ou desviam. O rádio só
## ouve os barcos que aparecem no canal aberto do monitor da mesa.

## Algum barco no canal aberto precisa de aviso: o rádio toca enquanto for verdade.
signal calling_changed(calling: bool)
signal boat_sank

const EVENT_BOAT := &"boat"

@export var boat_scene: PackedScene

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var boat_path: Path3D

var _config: BoatConfig = BoatConfig.new()
var _boats: Array[Boat] = []
var _fog_start: float = 0.0
var _fog_end: float = 0.0
var _beam_lit: bool = false
var _calling: bool = false
## Câmeras na ordem dos canais do monitor, nulas nos canais que não vigiam a rota; sem a lista,
## todo barco conta como visto.
var _channel_cameras: Array[Camera3D] = []
var _watched_channel: int = 0


## Sorteia a semente do RNG.
func _ready() -> void:
	rng.randomize()


## Avança os barcos e aplica o desfecho: quem passou some; quem afundou anima e emite
## `boat_sank`. Depois, atualiza o rádio.
func _process(delta: float) -> void:
	for boat: Boat in _boats.duplicate():
		boat.passage.tick(delta, _fog_start, _fog_end)
		match boat.passage.outcome:
			BoatPassage.Outcome.PASSED:
				_boats.erase(boat)
				boat.queue_free()
			BoatPassage.Outcome.SANK:
				_boats.erase(boat)
				boat.sink()
				boat_sank.emit()
	_refresh_calling()


## Guarda os valores de barcos da dificuldade.
func configure(config: BoatConfig) -> void:
	_config = config


## Registra o evento `boat`, tratado por `can_spawn` e `spawn`.
func register_events(events: EventDirector) -> void:
	events.register(EVENT_BOAT, can_spawn, spawn)


## Diz se há rota e se cabe mais um barco agora.
func can_spawn() -> bool:
	return boat_path != null and _boats.size() < _config.max_simultaneous_boats


## Cria um barco no início da rota e atualiza o rádio.
func spawn() -> void:
	var boat: Boat = boat_scene.instantiate()
	boat.passage = BoatPassage.new(_config.crossing_seconds)
	boat_path.add_child(boat)
	_boats.append(boat)
	_refresh_calling()


## Guarda o trecho da rota coberto pelo nevoeiro, em fração, e atualiza o rádio.
func set_route_fog(start: float, end: float) -> void:
	_fog_start = start
	_fog_end = end
	_refresh_calling()


## Guarda se o feixe está aceso, o que decide o efeito de atender o rádio.
func set_beam_lit(lit: bool) -> void:
	_beam_lit = lit


## Guarda as câmeras dos canais do monitor (só as que vigiam a rota contam) e o canal aberto
## agora, e atualiza o rádio.
func watch_cameras(cameras: Array[SecurityCamera], channel: int) -> void:
	_channel_cameras.clear()
	for camera: SecurityCamera in cameras:
		_channel_cameras.append(camera.get_camera() if camera.shows_boat_route else null)
	set_watched_channel(channel)


## Guarda o canal aberto no monitor e atualiza o rádio: barcos fora dele deixam de tocá-lo.
func set_watched_channel(channel: int) -> void:
	_watched_channel = channel
	_refresh_calling()


## Avisa os barcos que estão chamando no canal aberto, ao atender o rádio. Com o feixe aceso,
## eles desviam.
func warn_calling_boats() -> void:
	for boat: Boat in _boats.duplicate():
		if not _is_heard(boat):
			continue
		boat.passage.answer(_beam_lit)
		if boat.passage.outcome == BoatPassage.Outcome.DIVERTED:
			_boats.erase(boat)
			boat.divert()
	_refresh_calling()


## Emite `calling_changed` só quando passa a haver ou deixa de haver barco chamando no canal
## aberto.
func _refresh_calling() -> void:
	var calling: bool = false
	for boat: Boat in _boats:
		calling = calling or _is_heard(boat)
	if calling != _calling:
		_calling = calling
		calling_changed.emit(calling)


## Diz se o barco chama e aparece na câmera do canal aberto, o que faz o rádio tocar.
func _is_heard(boat: Boat) -> bool:
	if not boat.passage.is_calling(_fog_start, _fog_end):
		return false
	if _channel_cameras.is_empty():
		return true
	var camera: Camera3D = _channel_cameras[_watched_channel]
	return camera != null and camera.is_position_in_frustum(boat.global_position)
