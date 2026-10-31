class_name Game
extends Node3D
## Orquestra o plantão: aplica a dificuldade, liga os sinais entre jogador, farol, sistemas
## e HUD, e conduz as noites até a vitória ou a morte.

signal run_won(difficulty_id: StringName)
signal run_lost(cause: StringName)
signal exit_to_menu_requested

## Dificuldade usada ao rodar esta cena direto (sem passar pelo menu).
@export var default_difficulty: DifficultyConfig

var difficulty: DifficultyConfig
var run: RunState

@onready var _world: Node3D = %World
@onready var _player: Player = %Player
@onready var _lighthouse: Lighthouse = %Lighthouse
@onready var _exterior: Exterior = %Exterior
@onready var _night_director: NightDirector = %NightDirector
@onready var _event_director: EventDirector = %EventDirector
@onready var _fog: FogSystem = %FogSystem
@onready var _boats: BoatDirector = %BoatDirector
@onready var _drowned: DrownedDirector = %DrownedDirector
@onready var _fog_man: FogManDirector = %FogManDirector
@onready var _navigation: NavigationRegion3D = %Navigation
@onready var _hud: Hud = %Hud
@onready var _night_end: NightEndScreen = %NightEndScreen


func _ready() -> void:
	difficulty = default_difficulty
	run = RunState.new(difficulty.id, difficulty.nights)
	_configure_systems()
	_connect_signals()
	_night_director.start_night(run.current_night)
	# O CSG monta a geometria no primeiro frame; só então a navmesh enxerga o farol.
	await get_tree().process_frame
	_navigation.bake_navigation_mesh(false)


func _configure_systems() -> void:
	_player.configure(difficulty)
	_lighthouse.configure(difficulty)
	_night_director.configure(difficulty.time)
	_event_director.configure(difficulty)
	_fog.configure(difficulty.fog)
	_boats.configure(difficulty.boat)
	_boats.boat_path = _exterior.boat_path
	_drowned.configure(difficulty.threat, difficulty.drowned)
	_drowned.setup(_lighthouse, _player, _exterior)
	_fog_man.configure(difficulty.fog_man)
	_fog_man.setup(_player, _exterior)
	_lighthouse.register_events(_event_director)
	_fog.register_events(_event_director)
	_boats.register_events(_event_director)
	_lighthouse.show_camera_feeds(
		_exterior.sea_camera.get_feed(), _exterior.lighthouse_camera.get_feed()
	)


func _connect_signals() -> void:
	_player.interaction.focus_changed.connect(_hud.show_prompt)
	_player.interaction.hold_progress_changed.connect(_hud.show_hold_progress)
	_player.slowed_changed.connect(_hud.set_slowed)
	_player.died.connect(_on_player_died)
	_night_director.time_changed.connect(_lighthouse.show_time)
	_night_director.night_started.connect(_on_night_started)
	_night_director.night_ended.connect(_on_night_ended)
	_night_end.continue_requested.connect(_on_night_end_continue_requested)
	_night_end.menu_requested.connect(exit_to_menu_requested.emit)
	_lighthouse.jerrycan_carried_changed.connect(_player.set_carrying)
	_lighthouse.beam_active_changed.connect(_boats.set_beam_active)
	_lighthouse.radio.answered.connect(_on_radio_answered)
	_fog.intensity_changed.connect(_exterior.set_fog_intensity)
	_fog.intensity_changed.connect(_boats.set_fog_intensity)
	_fog.covers_lighthouse_camera_changed.connect(_fog_man.set_fog_covers_camera)
	_fog_man.player_blinded.connect(_hud.show_blindness)
	_boats.boat_arrived.connect(_on_boat_arrived)
	_boats.boat_gone.connect(_lighthouse.radio.stop_ringing)
	_boats.boat_sank.connect(_drowned.add_drowned_point)
	# Provisório até o passo 19 (SceneRouter): sem telas finais, recomeça a cena.
	run_won.connect(_restart_placeholder.unbind(1))
	run_lost.connect(_restart_placeholder.unbind(1))
	exit_to_menu_requested.connect(_restart_placeholder)


## Congela (ou retoma) toda a simulação; HUD e telas continuam respondendo.
func _set_simulation_running(running: bool) -> void:
	_world.process_mode = Node.PROCESS_MODE_INHERIT if running else Node.PROCESS_MODE_DISABLED
	_player.set_controls_enabled(running)
	if not running:
		_hud.show_prompt("")
		_hud.show_hold_progress(0.0, false)


## Às 06:00 a noite termina mesmo com algo em andamento (GDD 1.2.1): ameaças e barco somem;
## recursos, danos e ameaça acumulada continuam.
func _clear_night_entities() -> void:
	_boats.clear()
	_drowned.clear()
	_fog_man.clear()
	_fog.clear()


func _on_night_started(_night: int) -> void:
	_event_director.reset_night()


func _on_night_ended(night: int) -> void:
	_set_simulation_running(false)
	_clear_night_entities()
	if run.is_last_night():
		run_won.emit(run.difficulty_id)
	else:
		_night_end.show_night(night)


func _on_night_end_continue_requested() -> void:
	run.advance_night()
	_set_simulation_running(true)
	_night_director.start_night(run.current_night)


func _on_player_died(cause: StringName) -> void:
	_set_simulation_running(false)
	run_lost.emit(cause)


func _on_boat_arrived(is_pirate: bool, answered: bool) -> void:
	if not answered:
		_lighthouse.radio.ring(is_pirate)


func _on_radio_answered(_is_pirate: bool) -> void:
	_boats.mark_answered()


func _restart_placeholder() -> void:
	get_tree().reload_current_scene.call_deferred()
