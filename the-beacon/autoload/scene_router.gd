extends Node
## Autoload SceneRouter: troca entre menu principal e jogo e guarda o pedido de noite até
## a cena de jogo buscá-lo (decisões 0010 e 0015).

const MAIN_MENU_SCENE := "res://ui/main_menu/main_menu.tscn"
const GAME_SCENE := "res://game/game.tscn"

var _pending_run: RunRequest


## Troca para o menu principal.
func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)


## Começa um plantão novo na dificuldade dada, na primeira noite.
func start_new_run(difficulty: DifficultyConfig) -> void:
	play_night(difficulty, RunState.new_run(difficulty))


## Carrega a cena de jogo do zero para a noite atual do plantão. Plantão novo, próxima noite
## e Continuar passam todos por aqui.
func play_night(difficulty: DifficultyConfig, run: RunState) -> void:
	_pending_run = RunRequest.new(difficulty, run)
	_change_scene(GAME_SCENE)


## Entrega o pedido uma única vez. Nulo quando a cena de jogo abriu direto (editor, testes).
func take_run_request() -> RunRequest:
	var request: RunRequest = _pending_run
	_pending_run = null
	return request


## Fecha o jogo.
func quit_game() -> void:
	get_tree().quit()


## Troca de cena de forma adiada, para acontecer fora do handler de botão ou de sinal que a
## pediu.
func _change_scene(path: String) -> void:
	get_tree().change_scene_to_file.call_deferred(path)
