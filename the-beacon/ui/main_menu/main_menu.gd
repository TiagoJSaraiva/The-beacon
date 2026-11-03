class_name MainMenu
extends Control
## Menu principal, seleção de dificuldade e configurações (GDD 15.1 e 15.2).

@export var catalog: DifficultyCatalog

@onready var _main_page: Control = %MainPage
@onready var _difficulty_page: Control = %DifficultyPage
@onready var _settings_panel: SettingsPanel = %SettingsPanel
@onready var _new_game_button: Button = %NewGameButton
@onready var _continue_button: Button = %ContinueButton
@onready var _difficulty_buttons: VBoxContainer = %DifficultyButtons


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_continue_button.disabled = not SaveService.has_run_save()
	_build_difficulty_buttons()
	_settings_panel.back_requested.connect(_show_main_page)
	_show_main_page()


## Voltar (Esc, B no controle) sobe uma página.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or _main_page.visible:
		return
	get_viewport().set_input_as_handled()
	if _settings_panel.visible and _settings_panel.go_back_from_subpage():
		return
	if _settings_panel.visible:
		Settings.save()
	_show_main_page()


func _build_difficulty_buttons() -> void:
	for difficulty: DifficultyConfig in catalog.difficulties:
		var unlocked: bool = SaveService.is_unlocked(difficulty.id, catalog)
		var button := Button.new()
		button.text = "%s — %d noites" % [difficulty.display_name, difficulty.nights]
		if not unlocked:
			button.text += " (bloqueada)"
		button.disabled = not unlocked
		button.pressed.connect(_on_difficulty_chosen.bind(difficulty))
		_difficulty_buttons.add_child(button)


func _show_page(page: Control) -> void:
	for candidate: Control in [_main_page, _difficulty_page, _settings_panel]:
		candidate.visible = candidate == page


func _show_main_page() -> void:
	_show_page(_main_page)
	_new_game_button.grab_focus()


func _on_new_game_button_pressed() -> void:
	_show_page(_difficulty_page)
	var first_button := _difficulty_buttons.get_child(0) as Button
	if first_button != null:
		first_button.grab_focus()


func _on_continue_button_pressed() -> void:
	var run := RunState.new()
	run.from_dict(SaveService.read_run())
	var difficulty: DifficultyConfig = catalog.find_by_id(run.difficulty_id)
	if difficulty == null:
		push_warning("Save com dificuldade desconhecida; descartado")
		SaveService.delete_run()
		_continue_button.disabled = true
		return
	SceneRouter.play_night(difficulty, run)


func _on_settings_button_pressed() -> void:
	_settings_panel.refresh()
	_show_page(_settings_panel)
	_settings_panel.focus_first()


func _on_quit_button_pressed() -> void:
	SceneRouter.quit_game()


func _on_difficulty_chosen(difficulty: DifficultyConfig) -> void:
	# Novo Jogo sobrescreve o save existente (GDD 1.2.22).
	SaveService.delete_run()
	SceneRouter.start_new_run(difficulty)


func _on_difficulty_back_button_pressed() -> void:
	_show_main_page()
