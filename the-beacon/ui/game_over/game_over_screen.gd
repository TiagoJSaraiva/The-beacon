class_name GameOverScreen
extends CanvasLayer
## Tela de morte (GDD 15.2). O save já foi apagado: tentar de novo recomeça o plantão inteiro.

signal retry_requested
signal menu_requested
signal quit_requested

@onready var _retry_button: Button = %RetryButton


func _ready() -> void:
	visible = false


func show_screen() -> void:
	visible = true
	_retry_button.grab_focus()


func _on_retry_button_pressed() -> void:
	retry_requested.emit()


func _on_menu_button_pressed() -> void:
	menu_requested.emit()


func _on_quit_button_pressed() -> void:
	quit_requested.emit()
