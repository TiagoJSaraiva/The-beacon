class_name VictoryScreen
extends CanvasLayer
## Tela de plantão concluído (GDD 15.1): dificuldade e noites sobrevividas.

signal menu_requested

@onready var _details: Label = %Details
@onready var _menu_button: Button = %MenuButton


## Começa escondida.
func _ready() -> void:
	visible = false


## Mostra a dificuldade e as noites sobrevividas, com o foco no botão do menu.
func show_result(difficulty_name: String, nights: int) -> void:
	_details.text = "%s\nNoites sobrevividas: %d" % [difficulty_name, nights]
	visible = true
	_menu_button.grab_focus()


## Pede para voltar ao menu.
func _on_menu_button_pressed() -> void:
	menu_requested.emit()
