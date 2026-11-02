class_name ViewFocus
extends Node
## Vira o olhar do jogador para um ponto (ex.: a agenda aberta) e, ao soltar, devolve o olhar
## que ele tinha antes (GDD 1.2.22).

## Gira em Y (corpo do jogador).
@export var body: Node3D
## Gira em X (cabeça).
@export var head: Node3D
## Origem do olhar (câmera).
@export var eye: Node3D
@export var turn_seconds: float = 0.35

var _saved_yaw: float = 0.0
var _saved_pitch: float = 0.0
var _tween: Tween


func focus(target: Vector3) -> void:
	_saved_yaw = body.rotation.y
	_saved_pitch = head.rotation.x
	var to_target: Vector3 = target - eye.global_position
	# O olhar aponta para -Z: o giro em Y que alinha -Z com o alvo no plano horizontal.
	var yaw: float = atan2(-to_target.x, -to_target.z)
	var pitch: float = atan2(to_target.y, Vector2(to_target.x, to_target.z).length())
	_turn_to(yaw, pitch)


func release() -> void:
	_turn_to(_saved_yaw, _saved_pitch)


func _turn_to(yaw: float, pitch: float) -> void:
	if _tween != null:
		_tween.kill()
	# Pelo menor ângulo, para não dar uma volta inteira.
	var target_yaw: float = body.rotation.y + angle_difference(body.rotation.y, yaw)
	_tween = create_tween().set_parallel()
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(body, "rotation:y", target_yaw, turn_seconds)
	_tween.tween_property(head, "rotation:x", pitch, turn_seconds)
