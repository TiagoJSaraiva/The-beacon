class_name GameOverScreen
extends CanvasLayer
## Tela de morte (GDD 15.2). O save já foi apagado: tentar de novo recomeça o plantão inteiro.

signal retry_requested
signal menu_requested
signal quit_requested

@onready var _retry_button: Button = %RetryButton


## Começa escondida.
func _ready() -> void:
	visible = false


## Mostra a tela, com o foco em tentar de novo.
func show_screen() -> void:
	visible = true
	_retry_button.grab_focus()


## Pede para recomeçar o plantão.
func _on_retry_button_pressed() -> void:
	retry_requested.emit()


## Pede para voltar ao menu.
func _on_menu_button_pressed() -> void:
	menu_requested.emit()


## Pede para fechar o jogo.
func _on_quit_button_pressed() -> void:
	quit_requested.emit()
