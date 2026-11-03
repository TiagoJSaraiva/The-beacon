class_name NightEndScreen
extends CanvasLayer
## Tela entre noites (GDD 15.2): seguir para a próxima noite ou salvar e sair. É o único
## lugar onde o jogo salva (decisão 0014).

signal continue_requested
signal save_and_exit_requested

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


func _on_save_and_exit_button_pressed() -> void:
	visible = false
	save_and_exit_requested.emit()
