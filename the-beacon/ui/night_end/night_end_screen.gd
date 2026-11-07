class_name NightEndScreen
extends CanvasLayer
## Tela entre noites (GDD 15.2): seguir para a próxima noite ou salvar e sair. É o único
## lugar onde o jogo salva (decisão 0014).

signal continue_requested
signal save_and_exit_requested

@onready var _title: Label = %Title
@onready var _continue_button: Button = %ContinueButton


## Começa escondida.
func _ready() -> void:
	visible = false


## Mostra a tela da noite concluída, com o foco em continuar.
func show_night(night: int) -> void:
	_title.text = "Noite %d concluída" % night
	visible = true
	_continue_button.grab_focus()


## Esconde a tela e pede a próxima noite.
func _on_continue_button_pressed() -> void:
	visible = false
	continue_requested.emit()


## Esconde a tela e pede para salvar e sair.
func _on_save_and_exit_button_pressed() -> void:
	visible = false
	save_and_exit_requested.emit()
