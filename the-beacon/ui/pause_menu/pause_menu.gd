class_name PauseMenu
extends CanvasLayer
## Menu de pausa (decisão 0016): a ação `pause` pausa a partida e abre Continuar,
## Configurações e Sair para o menu. Sair perde a partida, porque o jogo só salva entre
## noites (decisão 0014). Roda com a árvore pausada (`process_mode = ALWAYS` na cena).

## A partida pausou (true) ou voltou a rodar (false).
signal paused_changed(paused: bool)
## O jogador confirmou a saída; a árvore já foi despausada.
signal exit_requested

## Desligado fora da simulação (fim de noite, morte, vitória).
var enabled: bool = true

@onready var _index_page: Control = %IndexPage
@onready var _settings_panel: SettingsPanel = %SettingsPanel
@onready var _exit_page: Control = %ExitPage
@onready var _resume_button: Button = %ResumeButton


## Começa escondido e liga o Voltar das configurações ao índice.
func _ready() -> void:
	visible = false
	_settings_panel.back_requested.connect(_show_index)


## Abre com `pause`, se estiver habilitado. Aberto, `pause` e `ui_cancel` voltam uma página e, no
## índice, fecham.
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		if enabled and event.is_action_pressed("pause"):
			get_viewport().set_input_as_handled()
			open()
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if _index_page.visible:
			close()
		elif _settings_panel.visible and _settings_panel.go_back_from_subpage():
			return
		else:
			# Sair das configurações pelo Esc grava como o botão Voltar.
			if _settings_panel.visible:
				Settings.save()
			_show_index()


## Pausa a árvore, mostra o índice e emite `paused_changed`.
func open() -> void:
	visible = true
	get_tree().paused = true
	_show_index()
	paused_changed.emit(true)


## Esconde o menu, despausa a árvore e emite `paused_changed`.
func close() -> void:
	visible = false
	get_tree().paused = false
	paused_changed.emit(false)


## Mostra só a página dada.
func _show_page(page: Control) -> void:
	for candidate: Control in [_index_page, _settings_panel, _exit_page]:
		candidate.visible = candidate == page


## Abre o índice, com o foco em Continuar.
func _show_index() -> void:
	_show_page(_index_page)
	_resume_button.grab_focus()


## Fecha o menu e retoma a partida.
func _on_resume_button_pressed() -> void:
	close()


## Abre as configurações com os valores atuais.
func _on_settings_button_pressed() -> void:
	_settings_panel.refresh()
	_show_page(_settings_panel)
	_settings_panel.focus_first()


## Abre a confirmação de saída.
func _on_exit_button_pressed() -> void:
	_show_page(_exit_page)


## Despausa a árvore e pede a saída para o menu.
func _on_exit_confirm_button_pressed() -> void:
	# A troca de cena manteria a árvore pausada.
	get_tree().paused = false
	exit_requested.emit()


## Cancela a saída e volta ao índice.
func _on_exit_cancel_button_pressed() -> void:
	_show_index()
