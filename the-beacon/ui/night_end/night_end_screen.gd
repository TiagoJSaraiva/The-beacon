class_name NightEndScreen
extends CanvasLayer
## Tela entre noites (GDD 15.2): continuar para a próxima noite ou voltar ao menu.
## Não salva nada: o jogo só salva pela agenda.

signal continue_requested
signal menu_requested

@onready var _title: Label = %Title
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	visible = false


func show_night(night: int) -> void:
	_title.text = "Noite %d concluída" % night
	visible = true
	_continue_button.grab_focus()


func _on_continue_button_pressed() -> void:
	visible = false
	continue_requested.emit()


func _on_menu_button_pressed() -> void:
	visible = false
	menu_requested.emit()
