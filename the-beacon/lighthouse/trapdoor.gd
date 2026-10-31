class_name Trapdoor
extends Node3D
## Alçapão no topo da escada (GDD 1.2.11). Abre e fecha só por cima; o trinco é um
## objeto separado, ao lado, que o jogador segura enquanto o alçapão está fechado.
## Este nó fica na dobradiça (borda longa); o painel abre girando para cima em torno do
## eixo X local.

signal state_changed(state: State)
signal latch_held_changed(held: bool)

enum State { CLOSED, OPEN, BROKEN }

@export var open_angle_degrees: float = 90.0
@export var swing_seconds: float = 0.35
## Altura mínima dos pés de quem interage, relativa à dobradiça. Impede operar por baixo.
@export var min_user_height: float = -0.25

var state: State = State.CLOSED
var resistance := TrapdoorResistance.new(TrapdoorConfig.new().resistance_seconds)

var _swing: Tween
var _banging: bool = false

@onready var _panel: Node3D = %Panel
@onready var _panel_collision: CollisionShape3D = %PanelCollision
@onready var _panel_interactable: Interactable = %PanelInteractable
@onready var _latch_interactable: Interactable = %LatchInteractable
@onready var _bang_sound: LoopingSound = %BangSound


func _ready() -> void:
	_panel_interactable.usable_check = _is_above
	_latch_interactable.usable_check = _is_above
	_apply_state(false)


func _process(delta: float) -> void:
	if state != State.CLOSED:
		return
	if resistance.tick(delta, _banging, is_latch_held()):
		break_open()


func configure(config: TrapdoorConfig) -> void:
	resistance = TrapdoorResistance.new(config.resistance_seconds)


## Afogados batendo por baixo. Quando todos vão embora, a resistência volta ao máximo.
func set_banging(banging: bool) -> void:
	if _banging and not banging:
		resistance.reset()
	_banging = banging
	_bang_sound.set_active(banging and state == State.CLOSED)


func is_latch_held() -> bool:
	return _latch_interactable.is_held


func toggle() -> void:
	match state:
		State.CLOSED:
			_set_state(State.OPEN)
		State.OPEN:
			_set_state(State.CLOSED)


func break_open() -> void:
	_set_state(State.BROKEN)


func to_dict() -> Dictionary:
	return {"state": state, "resistance": resistance.to_dict()}


func from_dict(data: Dictionary) -> void:
	var saved: int = data.get("state", State.CLOSED)
	state = saved as State
	resistance.from_dict(data.get("resistance", {}))
	_apply_state(false)


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	_apply_state(true)
	state_changed.emit(state)


func _apply_state(animate: bool) -> void:
	var target_angle: float = deg_to_rad(open_angle_degrees) if state == State.OPEN else 0.0
	if _swing != null:
		_swing.kill()
	if animate:
		_swing = create_tween()
		_swing.tween_property(_panel, "rotation:x", -target_angle, swing_seconds)
	else:
		_panel.rotation.x = -target_angle
	var broken: bool = state == State.BROKEN
	_bang_sound.set_active(_banging and state == State.CLOSED)
	_panel.visible = not broken
	_panel_collision.set_deferred("disabled", broken)
	_panel_interactable.enabled = not broken
	_latch_interactable.enabled = state == State.CLOSED
	if not _latch_interactable.enabled:
		_latch_interactable.set_held(false)


func _is_above(user: Node3D) -> bool:
	return user != null and user.global_position.y >= global_position.y + min_user_height


func _on_panel_interactable_interacted() -> void:
	toggle()


func _on_latch_interactable_hold_state_changed(held: bool) -> void:
	latch_held_changed.emit(held)
