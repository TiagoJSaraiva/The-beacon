class_name Trapdoor
extends CSGBox3D
## Alçapão no topo da escada (entrega 2; regras em `TrapdoorRules`). Abre e fecha só por
## cima; o trinco, ao lado, liga e desliga. A raiz é o buraco no piso (decisão 0019) e
## precisa ser filha direta do CSG que corta. O painel tem a origem na dobradiça (borda
## longa) e abre girando para cima em torno do eixo X local.

signal state_changed(state: State)
signal latch_changed(latched: bool)

enum State { CLOSED, OPEN }

@export var open_angle_degrees: float = 90.0
@export var swing_seconds: float = 0.35
## Altura mínima dos pés de quem interage, relativa à dobradiça. Impede operar por baixo.
@export var min_user_height: float = -0.25
@export var latched_bolt_degrees: float = 90.0

var rules: TrapdoorRules = TrapdoorRules.new(TrapdoorConfig.new())
var state: State:
	get:
		return State.OPEN if rules.is_open else State.CLOSED

var _swing: Tween
var _banging: bool = false

@onready var _panel: Node3D = %Panel
@onready var _panel_interactable: Interactable = %PanelInteractable
@onready var _latch_interactable: Interactable = %LatchInteractable
@onready var _latch_bolt: Node3D = %LatchBolt
@onready var _bang_sound: LoopingSound = %BangSound


## Restringe o painel e o trinco a quem está em cima e aplica o estado inicial.
func _ready() -> void:
	_panel_interactable.usable_check = _is_above
	_latch_interactable.usable_check = _is_above
	_apply_state(false)


## Avança os tempos das regras e atualiza o que pode ser usado. Se o Afogado abrir o alçapão,
## anima e emite `state_changed`.
func _process(delta: float) -> void:
	if rules.tick(delta, _banging):
		_apply_state(true)
		state_changed.emit(state)
	# Os intervalos liberam e bloqueiam as interações com o tempo.
	_refresh_interactables()


## Recria as regras com os valores da dificuldade e ajusta o trinco: um toque com duração zero;
## senão, segurar até completar.
func configure(config: TrapdoorConfig) -> void:
	rules = TrapdoorRules.new(config)
	var instant: bool = config.latch_toggle_seconds <= 0.0
	_latch_interactable.mode = Interactable.Mode.PRESS if instant else Interactable.Mode.HOLD
	_latch_interactable.hold_seconds = config.latch_toggle_seconds
	_apply_state(false)


## Informa se o Afogado está batendo por baixo. O som só toca com o alçapão fechado.
func set_banging(banging: bool) -> void:
	_banging = banging
	_bang_sound.set_active(banging and state == State.CLOSED)


## Diz se o trinco está ligado.
func is_latched() -> bool:
	return rules.is_latched


## Informa se há nevoeiro no alçapão. Com ele, o trinco desliga e não pode ser ligado; emite
## `latch_changed` se mudou.
func set_fog_present(present: bool) -> void:
	var was_latched: bool = rules.is_latched
	rules.set_fog_present(present)
	if rules.is_latched != was_latched:
		_apply_state(true)
		latch_changed.emit(rules.is_latched)


## Leva o painel e a trava à posição das regras, com ou sem animação, e atualiza o som e os
## interativos.
func _apply_state(animate: bool) -> void:
	var target_angle: float = deg_to_rad(open_angle_degrees) if rules.is_open else 0.0
	if _swing != null:
		_swing.kill()
	if animate:
		_swing = create_tween()
		_swing.tween_property(_panel, "rotation:x", -target_angle, swing_seconds)
	else:
		_panel.rotation.x = -target_angle
	_latch_bolt.rotation.y = deg_to_rad(latched_bolt_degrees) if rules.is_latched else 0.0
	_bang_sound.set_active(_banging and state == State.CLOSED)
	_refresh_interactables()


## Ativa o painel e o trinco só quando as regras permitem usá-los.
func _refresh_interactables() -> void:
	_panel_interactable.enabled = rules.can_toggle_open()
	_latch_interactable.enabled = rules.can_toggle_latch()


## Tenta inverter o trinco e, se mudou, atualiza a cena e emite `latch_changed`.
func _toggle_latch() -> void:
	var was_latched: bool = rules.is_latched
	rules.toggle_latch()
	if rules.is_latched != was_latched:
		_apply_state(true)
		latch_changed.emit(rules.is_latched)


## Diz se os pés de quem interage estão na altura mínima, o que impede operar por baixo.
func _is_above(user: Node3D) -> bool:
	return user != null and user.global_position.y >= _panel.global_position.y + min_user_height


## Abre ou fecha o painel, se as regras permitirem, e emite `state_changed`.
func _on_panel_interactable_interacted() -> void:
	if rules.toggle_open():
		_apply_state(true)
		state_changed.emit(state)


## Inverte o trinco no toque (duração zero).
func _on_latch_interactable_interacted() -> void:
	_toggle_latch()


## Inverte o trinco ao completar a barra.
func _on_latch_interactable_hold_completed() -> void:
	_toggle_latch()
