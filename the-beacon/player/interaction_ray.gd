class_name InteractionRay
extends RayCast3D
## Mira do jogador: encontra o Interactable à frente e traduz a tecla de interação
## em toque, segurar até completar ou segurar contínuo.

## Algo usável entrou (true) ou saiu (false) da mira; a HUD mostra a tecla de interagir.
signal focus_changed(focused: bool)
signal hold_progress_changed(ratio: float, active: bool)
## Usou algo de mãos livres com o galão na mão: soltar o galão primeiro.
signal drop_requested

## Corpo de quem interage, repassado aos objetos que restringem o uso (ex.: alçapão).
@export var user: Node3D

## Ligado pelo jogador enquanto carrega o galão.
var hands_busy: bool = false
var input_enabled: bool = true

var _focused: Interactable
var _progress: HoldProgress
# Depois de uma interação completa, só aceita outra quando a tecla for solta.
var _awaiting_release: bool = false


func _ready() -> void:
	collide_with_areas = true
	collision_mask = CollisionLayers.WORLD | CollisionLayers.BARRIERS | CollisionLayers.INTERACTABLE


func _physics_process(delta: float) -> void:
	# Sem controle (pausa, telas), nada fica em foco e a HUD não mostra a hotkey.
	var target: Interactable = _find_target() if input_enabled else null
	if target != _focused:
		_change_focus(target)
	if _focused == null:
		return
	var pressed: bool = input_enabled and Input.is_action_pressed("interact")
	if not pressed:
		_awaiting_release = false
		_stop_hold()
		return
	if _awaiting_release:
		return
	if hands_busy and _focused.hands_rule == Interactable.HandsRule.FREE:
		_awaiting_release = true
		drop_requested.emit()
		return
	match _focused.mode:
		Interactable.Mode.PRESS:
			_focused.interact()
			_awaiting_release = true
		Interactable.Mode.HOLD:
			_advance_hold(delta)
		Interactable.Mode.HOLD_CONTINUOUS:
			_focused.set_held(true)


func _advance_hold(delta: float) -> void:
	if _progress == null:
		_progress = HoldProgress.new(_focused.hold_seconds)
	var completed: bool = _progress.advance(delta)
	hold_progress_changed.emit(_progress.ratio(), not completed)
	if completed:
		_progress = null
		_awaiting_release = true
		_focused.complete_hold()


func _stop_hold() -> void:
	if _progress != null:
		_progress = null
		hold_progress_changed.emit(0.0, false)
	if _focused != null:
		_focused.set_held(false)


func _change_focus(target: Interactable) -> void:
	_stop_hold()
	_focused = target
	# Segurar E enquanto vira para outro objeto não deve disparar o novo.
	_awaiting_release = Input.is_action_pressed("interact")
	focus_changed.emit(target != null)


func _find_target() -> Interactable:
	if not is_colliding():
		return null
	var target := get_collider() as Interactable
	if target == null:
		return null
	# De mãos ocupadas, o que exige mãos livres continua em foco: usar solta o galão.
	var free_hands_target: bool = target.hands_rule == Interactable.HandsRule.FREE
	if not target.can_be_used(hands_busy and not free_hands_target, user):
		return null
	return target
