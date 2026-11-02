class_name AgendaOverlay
extends CanvasLayer
## Páginas da agenda aberta, com opções clicáveis (GDD 1.2.22). O jogo não pausa: o mundo
## continua rodando por trás e quem decide o que cada opção faz é o Game.

## O jogador fechou a agenda (botão ou Esc).
signal closed
signal save_and_exit_requested
signal exit_without_saving_requested

@onready var _index_page: Control = %IndexPage
@onready var _settings_panel: SettingsPanel = %SettingsPanel
@onready var _discard_page: Control = %DiscardPage
@onready var _save_button: Button = %SaveButton


func _ready() -> void:
	visible = false
	_settings_panel.back_requested.connect(_show_index)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _index_page.visible:
		_close()
	else:
		_show_index()


func open() -> void:
	visible = true
	_show_index()


## Esconde sem avisar (morte, fim da noite): quem chamou já cuida do resto.
func dismiss() -> void:
	visible = false


func _show_page(page: Control) -> void:
	for candidate: Control in [_index_page, _settings_panel, _discard_page]:
		candidate.visible = candidate == page


func _show_index() -> void:
	_show_page(_index_page)
	_save_button.grab_focus()


func _close() -> void:
	visible = false
	closed.emit()


func _on_settings_button_pressed() -> void:
	_settings_panel.refresh()
	_show_page(_settings_panel)
	_settings_panel.focus_first()


func _on_save_button_pressed() -> void:
	save_and_exit_requested.emit()


func _on_discard_button_pressed() -> void:
	_show_page(_discard_page)


func _on_discard_confirm_button_pressed() -> void:
	exit_without_saving_requested.emit()


func _on_discard_cancel_button_pressed() -> void:
	_show_index()


func _on_close_button_pressed() -> void:
	_close()
