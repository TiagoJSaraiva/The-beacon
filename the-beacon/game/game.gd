class_name Game
extends Node3D
## Orquestra o plantão: aplica a dificuldade (ou restaura o save), liga os sinais entre
## jogador, farol, sistemas e HUD, e conduz as noites até a vitória ou a morte.

signal run_won(difficulty_id: StringName)
signal run_lost(cause: StringName)

## Dificuldade usada ao rodar esta cena direto (sem passar pelo menu).
@export var default_difficulty: DifficultyConfig
## Ordem de desbloqueio e busca da dificuldade de um save.
@export var catalog: DifficultyCatalog

var difficulty: DifficultyConfig
var run: RunState

var _saved_run: Dictionary = {}

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
@onready var _tutorial: TutorialDirector = %TutorialDirector
@onready var _navigation: NavigationRegion3D = %Navigation
@onready var _hud: Hud = %Hud
@onready var _night_end: NightEndScreen = %NightEndScreen
@onready var _game_over: GameOverScreen = %GameOverScreen
@onready var _victory: VictoryScreen = %VictoryScreen
@onready var _agenda: AgendaController = %AgendaController
@onready var _snapshot: RunSnapshot = %RunSnapshot


func _ready() -> void:
	difficulty = default_difficulty
	_read_run_request()
	run = RunState.new(difficulty.id, difficulty.nights)
	_configure_systems()
	_connect_signals()
	_apply_settings()
	if _saved_run.is_empty():
		_night_director.start_night(run.current_night)
	else:
		_snapshot.restore(_saved_run, run)
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
	_tutorial.setup(
		difficulty.tutorial_enabled, _night_director, _lighthouse, _fog, _boats, _drowned, _fog_man
	)
	_agenda.setup(run, _lighthouse.agenda)
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
	_tutorial.message_changed.connect(_hud.show_tutorial)
	_player.died.connect(_on_player_died)
	_night_director.time_changed.connect(_lighthouse.show_time)
	_night_director.night_started.connect(_on_night_started)
	_night_director.night_ended.connect(_on_night_ended)
	_night_end.continue_requested.connect(_on_night_end_continue_requested)
	_night_end.menu_requested.connect(SceneRouter.go_to_main_menu)
	_game_over.retry_requested.connect(_on_game_over_retry_requested)
	_game_over.menu_requested.connect(SceneRouter.go_to_main_menu)
	_game_over.quit_requested.connect(SceneRouter.quit_game)
	_victory.menu_requested.connect(SceneRouter.go_to_main_menu)
	Settings.changed.connect(_apply_settings)
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


## Usa a dificuldade escolhida no menu ou a do save; sem pedido (cena aberta direto) ou com
## um save de dificuldade desconhecida, começa um plantão novo na padrão.
func _read_run_request() -> void:
	var request: RunRequest = SceneRouter.take_run_request()
	if request == null:
		return
	if request.difficulty != null:
		difficulty = request.difficulty
		return
	var saved_difficulty: DifficultyConfig = catalog.find_by_id(
		RunSnapshot.difficulty_id_of(request.saved_run)
	)
	if saved_difficulty == null:
		push_warning("Save com dificuldade desconhecida; começando um plantão novo")
		return
	difficulty = saved_difficulty
	_saved_run = request.saved_run


func _apply_settings() -> void:
	_player.sensitivity_scale = Settings.state.sensitivity_scale


## Congela (ou retoma) toda a simulação; HUD e telas continuam respondendo.
func _set_simulation_running(running: bool) -> void:
	_world.process_mode = Node.PROCESS_MODE_INHERIT if running else Node.PROCESS_MODE_DISABLED
	_player.set_controls_enabled(running)
	if not running:
		_agenda.dismiss()
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
		_win_run()
	else:
		_night_end.show_night(night)


func _on_night_end_continue_requested() -> void:
	run.advance_night()
	_set_simulation_running(true)
	_night_director.start_night(run.current_night)


func _on_player_died(cause: StringName) -> void:
	_set_simulation_running(false)
	# Morrer perde o plantão inteiro (GDD 1.2.15).
	SaveService.delete_run()
	_game_over.show_screen()
	run_lost.emit(cause)


func _on_game_over_retry_requested() -> void:
	SceneRouter.start_new_run(difficulty)


## Vencer apaga o save e libera a próxima dificuldade (GDD 1.2.14 e 1.2.15).
func _win_run() -> void:
	SaveService.delete_run()
	SaveService.register_victory(difficulty.id, catalog)
	_victory.show_result(difficulty.display_name, run.total_nights)
	run_won.emit(difficulty.id)


func _on_boat_arrived(is_pirate: bool, answered: bool) -> void:
	if not answered:
		_lighthouse.radio.ring(is_pirate)


func _on_radio_answered(_is_pirate: bool) -> void:
	_boats.mark_answered()
