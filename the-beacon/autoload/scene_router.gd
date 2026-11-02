extends Node
## Autoload SceneRouter: troca entre menu principal e jogo e guarda o pedido de partida até
## a cena de jogo buscá-lo (decisão 0010).

const MAIN_MENU_SCENE := "res://ui/main_menu/main_menu.tscn"
const GAME_SCENE := "res://game/game.tscn"

var _pending_run: RunRequest


func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)


func start_new_run(difficulty: DifficultyConfig) -> void:
	_pending_run = RunRequest.new(difficulty)
	_change_scene(GAME_SCENE)


func continue_run(saved_run: Dictionary) -> void:
	_pending_run = RunRequest.new(null, saved_run)
	_change_scene(GAME_SCENE)


## Entrega o pedido uma única vez. Nulo quando a cena de jogo abriu direto (editor, testes).
func take_run_request() -> RunRequest:
	var request: RunRequest = _pending_run
	_pending_run = null
	return request


func quit_game() -> void:
	get_tree().quit()


# Adiado: a troca acontece fora do handler de botão ou de sinal que a pediu.
func _change_scene(path: String) -> void:
	get_tree().change_scene_to_file.call_deferred(path)
