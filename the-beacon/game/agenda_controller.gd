class_name AgendaController
extends Node
## Agenda durante a partida (GDD 1.2.22): ao abrir, trava o jogador e vira o olhar para ela;
## as opções viram "salvar e sair" ou "sair sem salvar". O mundo nunca pausa.

@export var overlay: AgendaOverlay
@export var player: Player
@export var hud: Hud
@export var snapshot: RunSnapshot

var _run: RunState
var _agenda: Agenda


func _ready() -> void:
	overlay.closed.connect(_on_overlay_closed)
	overlay.save_and_exit_requested.connect(_on_save_and_exit_requested)
	overlay.exit_without_saving_requested.connect(_on_exit_without_saving_requested)


func setup(run: RunState, agenda: Agenda) -> void:
	_run = run
	_agenda = agenda
	_agenda.open_requested.connect(_on_agenda_open_requested)


## Fecha sem devolver o controle (morte ou fim da noite: quem chamou cuida do jogador).
func dismiss() -> void:
	overlay.dismiss()


func _on_agenda_open_requested() -> void:
	player.set_controls_enabled(false)
	hud.show_hold_progress(0.0, false)
	player.view_focus.focus(_agenda.view_target_position())
	overlay.open()


func _on_overlay_closed() -> void:
	player.view_focus.release()
	player.set_controls_enabled(true)


func _on_save_and_exit_requested() -> void:
	SaveService.write_run(snapshot.capture(_run))
	SceneRouter.go_to_main_menu()


func _on_exit_without_saving_requested() -> void:
	# Perde tudo, inclusive um save anterior: impede salvar, arriscar e sair se der errado.
	SaveService.delete_run()
	SceneRouter.go_to_main_menu()
