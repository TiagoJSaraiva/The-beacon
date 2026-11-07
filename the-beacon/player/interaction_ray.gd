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


## Faz o raio detectar áreas e colidir com paredes, barreiras e interativos.
func _ready() -> void:
	collide_with_areas = true
	collision_mask = CollisionLayers.WORLD | CollisionLayers.BARRIERS | CollisionLayers.INTERACTABLE


## Atualiza o alvo em foco e traduz a tecla de interação conforme o modo dele. Com o galão na
## mão, usar um alvo de mãos livres só pede para soltar o galão.
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


## Avança a barra do alvo e publica o progresso. Ao completar, avisa o alvo e exige soltar a
## tecla.
func _advance_hold(delta: float) -> void:
	if _progress == null:
		_progress = HoldProgress.new(_focused.hold_seconds)
	var completed: bool = _progress.advance(delta)
	hold_progress_changed.emit(_progress.ratio(), not completed)
	if completed:
		_progress = null
		_awaiting_release = true
		_focused.complete_hold()


## Cancela a barra em andamento, se houver, e publica o progresso zerado.
func _stop_hold() -> void:
	if _progress != null:
		_progress = null
		hold_progress_changed.emit(0.0, false)


## Troca o alvo em foco, cancelando a interação anterior, e emite `focus_changed`.
func _change_focus(target: Interactable) -> void:
	_stop_hold()
	_focused = target
	# Segurar E enquanto vira para outro objeto não deve disparar o novo.
	_awaiting_release = Input.is_action_pressed("interact")
	focus_changed.emit(target != null)


## Devolve o primeiro interativo usável na mira, ou null. Paredes e barreiras param a busca.
func _find_target() -> Interactable:
	# Áreas podem se sobrepor (o ponto de devolução envolve o galão no slot): o que não pode
	# ser usado agora deixa o raio seguir até o próximo alvo. Só paredes e barreiras o param.
	var target: Interactable = null
	while is_colliding():
		var candidate := get_collider() as Interactable
		if candidate == null:
			break
		if _can_focus(candidate):
			target = candidate
			break
		add_exception(candidate)
		force_raycast_update()
	clear_exceptions()
	return target


## Diz se o alvo pode ficar em foco com o estado atual das mãos.
func _can_focus(target: Interactable) -> bool:
	# De mãos ocupadas, o que exige mãos livres continua em foco: usar solta o galão.
	var free_hands_target: bool = target.hands_rule == Interactable.HandsRule.FREE
	return target.can_be_used(hands_busy and not free_hands_target, user)
