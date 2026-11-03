class_name Game
extends Node3D
## Uma noite do plantão (decisão 0015): aplica a dificuldade e o estado que veio das noites
## anteriores, liga os sinais entre jogador, farol, sistemas e HUD, e às 06:00 recolhe o
## estado para a noite seguinte, a vitória ou o save.

signal run_won(difficulty_id: StringName)
signal run_lost(cause: StringName)

## Dificuldade usada ao rodar esta cena direto (sem passar pelo menu).
@export var default_difficulty: DifficultyConfig
## Ordem de desbloqueio das dificuldades.
@export var catalog: DifficultyCatalog

var difficulty: DifficultyConfig
var run: RunState

@onready var _world: Node3D = %World
@onready var _player: Player = %Player
@onready var _lighthouse: Lighthouse = %Lighthouse
@onready var _exterior: Exterior = %Exterior
@onready var _night_director: NightDirector = %NightDirector
@onready var _event_director: EventDirector = %EventDirector
@onready var _fog: FogSystem = %FogSystem
@onready var _fog_visuals: FogVisuals = %FogVisuals
@onready var _boats: BoatDirector = %BoatDirector
@onready var _drowned: DrownedDirector = %DrownedDirector
@onready var _fog_man: FogManDirector = %FogManDirector
@onready var _tutorial: TutorialDirector = %TutorialDirector
@onready var _navigation: NavigationRegion3D = %Navigation
@onready var _hud: Hud = %Hud
@onready var _night_end: NightEndScreen = %NightEndScreen
@onready var _game_over: GameOverScreen = %GameOverScreen
@onready var _victory: VictoryScreen = %VictoryScreen
@onready var _pause_menu: PauseMenu = %PauseMenu
@onready var _carryover: RunCarryover = %RunCarryover


func _ready() -> void:
	_read_run_request()
	# Começar a noite consome o save: qualquer saída antes do próximo "Salvar e sair",
	# inclusive fechar o jogo à força, perde a partida (decisão 0014).
	SaveService.delete_run()
	_configure_systems()
	_connect_signals()
	_apply_settings()
	_carryover.apply(run)
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
	_tutorial.setup(
		difficulty.tutorial_enabled, _night_director, _lighthouse, _fog, _boats, _drowned, _fog_man
	)
	_lighthouse.register_events(_event_director)
	_fog.register_events(_event_director)
	_boats.register_events(_event_director)
	_lighthouse.show_camera_feeds(
		_exterior.sea_camera_left.get_feed(),
		_exterior.sea_camera_right.get_feed(),
		_exterior.door_camera.get_feed()
	)
	_fog_visuals.setup(_fog, _exterior.boat_path)


func _connect_signals() -> void:
	_player.interaction.focus_changed.connect(_hud.show_prompt)
	_player.interaction.hold_progress_changed.connect(_hud.show_hold_progress)
	_player.sprint_blocked_changed.connect(_hud.set_hurt_border)
	_tutorial.message_changed.connect(_hud.show_tutorial)
	_player.died.connect(_on_player_died)
	_night_director.time_changed.connect(_lighthouse.show_time)
	_night_director.night_started.connect(_on_night_started)
	_night_director.night_ended.connect(_on_night_ended)
	_night_end.continue_requested.connect(_on_night_end_continue_requested)
	_night_end.save_and_exit_requested.connect(_on_night_end_save_and_exit_requested)
	_game_over.retry_requested.connect(_on_game_over_retry_requested)
	_game_over.menu_requested.connect(SceneRouter.go_to_main_menu)
	_game_over.quit_requested.connect(SceneRouter.quit_game)
	_victory.menu_requested.connect(SceneRouter.go_to_main_menu)
	_pause_menu.paused_changed.connect(_on_pause_menu_paused_changed)
	_pause_menu.exit_requested.connect(_on_pause_menu_exit_requested)
	Settings.changed.connect(_apply_settings)
	_lighthouse.jerrycan_carried_changed.connect(_player.set_carrying)
	_lighthouse.chair.sit_requested.connect(_player.sit)
	_player.drop_requested.connect(_lighthouse.drop_jerrycan)
	_lighthouse.beam_operational_changed.connect(_fog.set_beam_operational)
	_lighthouse.beam_lit_changed.connect(_boats.set_beam_lit)
	_lighthouse.radio.answered.connect(_boats.warn_calling_boats)
	_fog.stage_changed.connect(_lighthouse.set_fog_stage)
	_fog.stage_changed.connect(_fog_man.set_fog_stage)
	_fog.route_fog_changed.connect(_boats.set_route_fog)
	_fog_man.player_blinded.connect(_hud.show_blindness)
	_boats.calling_changed.connect(_lighthouse.radio.set_ringing)
	_boats.boat_sank.connect(_drowned.add_drowned_point)


## Usa o pedido do SceneRouter; sem pedido (cena aberta direto no editor ou em teste),
## começa um plantão novo na dificuldade padrão.
func _read_run_request() -> void:
	var request: RunRequest = SceneRouter.take_run_request()
	if request == null:
		difficulty = default_difficulty
		run = RunState.new_run(difficulty)
		return
	difficulty = request.difficulty
	run = request.run


func _apply_settings() -> void:
	_player.sensitivity_scale = Settings.state.sensitivity_scale


## Congela (ou retoma) toda a simulação; HUD e telas continuam respondendo.
func _set_simulation_running(running: bool) -> void:
	_world.process_mode = Node.PROCESS_MODE_INHERIT if running else Node.PROCESS_MODE_DISABLED
	_player.set_controls_enabled(running)
	_pause_menu.enabled = running
	if not running:
		_hud.show_prompt("")
		_hud.show_hold_progress(0.0, false)


func _on_night_started(_night: int) -> void:
	_event_director.reset_night()


## Às 06:00 a noite termina mesmo com algo em andamento (GDD 1.2.1). Só o estado
## persistente segue; a próxima noite recarrega a cena do zero.
func _on_night_ended(night: int) -> void:
	_set_simulation_running(false)
	_carryover.capture(run)
	if run.is_last_night():
		_win_run()
	else:
		run.advance_night()
		_night_end.show_night(night)


func _on_night_end_continue_requested() -> void:
	SceneRouter.play_night(difficulty, run)


## O save já aponta para a noite seguinte (decisão 0014).
func _on_night_end_save_and_exit_requested() -> void:
	SaveService.write_run(run.to_dict())
	SceneRouter.go_to_main_menu()


func _on_pause_menu_paused_changed(paused: bool) -> void:
	_player.set_controls_enabled(not paused)
	if paused:
		_hud.show_hold_progress(0.0, false)


## O save já foi consumido ao começar a noite: sair daqui perde a partida (decisão 0014).
func _on_pause_menu_exit_requested() -> void:
	SceneRouter.go_to_main_menu()


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
