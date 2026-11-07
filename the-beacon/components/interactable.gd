class_name Interactable
extends Area3D
## Ponto de interação de um objeto do cenário. Não sabe o efeito: o dono escuta os sinais.
## Precisa de um CollisionShape3D filho; fica na camada interactable.

signal interacted
signal hold_completed

## PRESS: um toque. HOLD: segurar até completar a barra.
enum Mode { PRESS, HOLD }
## Restrição pelo galão na mão (GDD 1.2.24): qualquer, mãos livres ou carregando.
enum HandsRule { ANY, FREE, CARRYING }

@export var mode: Mode = Mode.PRESS
## Duração do modo HOLD. O dono costuma sobrescrever com o valor da configuração.
@export var hold_seconds: float = 1.0
@export var hands_rule: HandsRule = HandsRule.ANY
@export var enabled: bool = true

## Checagem extra opcional do dono: recebe quem interage e diz se pode usar.
var usable_check: Callable


## Coloca a área na camada interactable, só para ser encontrada pelo raio: ela não detecta nada.
func _ready() -> void:
	collision_layer = CollisionLayers.INTERACTABLE
	collision_mask = 0
	monitoring = false


## Diz se o objeto aceita uso agora: precisa estar ligado, respeitar a regra das mãos e passar
## pela checagem opcional do dono.
func can_be_used(hands_busy: bool, user: Node3D) -> bool:
	if not enabled:
		return false
	if hands_rule == HandsRule.FREE and hands_busy:
		return false
	if hands_rule == HandsRule.CARRYING and not hands_busy:
		return false
	return not usable_check.is_valid() or usable_check.call(user)


## Emite `interacted`, o toque do modo PRESS.
func interact() -> void:
	interacted.emit()


## Emite `hold_completed`, a barra cheia do modo HOLD.
func complete_hold() -> void:
	hold_completed.emit()
