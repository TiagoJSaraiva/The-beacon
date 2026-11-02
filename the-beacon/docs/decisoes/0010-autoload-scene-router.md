# 0010 — Autoload SceneRouter para trocar entre menu e jogo

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O meta-jogo tem duas cenas raiz: o menu principal (Main Scene) e o jogo. O menu precisa dizer ao jogo qual dificuldade começar ou qual save continuar, e as telas do jogo (game over, vitória, fim de noite, agenda) precisam voltar ao menu ou recomeçar o plantão. Uma troca de cena destrói a cena anterior, então o pedido precisa sobreviver a ela.

## Decisão
Autoload `SceneRouter` (`autoload/scene_router.gd`), sem estado de jogo:
- `go_to_main_menu()`, `start_new_run(difficulty)`, `continue_run(saved_run)`, `quit_game()`.
- Guarda um `RunRequest` (`autoload/run_request.gd`: dificuldade ou save) até o `Game` buscá-lo uma única vez com `take_run_request()`. Sem pedido (cena aberta direto no editor ou em teste), o `Game` usa a `default_difficulty`.
- A troca é adiada (`call_deferred`) para não acontecer dentro do handler que a pediu.

## Alternativas descartadas
- **Cena raiz única que troca filhos**: evita autoload, mas cria uma cena "casca" e espalha a fiação de menu e jogo num só lugar.
- **Passar a dificuldade por metadados da árvore** (`get_tree().set_meta`): global da mesma forma, só que sem tipo e sem lugar óbvio para ler.

## Consequências
Telas e menu só falam com o `SceneRouter`; o `Game` não sabe de onde veio o pedido. É o único lugar que conhece os caminhos das cenas raiz.
