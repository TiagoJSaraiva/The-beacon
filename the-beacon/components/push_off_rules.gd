class_name PushOffRules
extends RefCounted
## Regras do empurrão no topo de uma máquina (regra pura): para qual borda empurrar quem para em
## cima dela e como o empurrão se soma ao andar do jogador.


## Devolve a direção (unitária, no plano XZ local do topo) da borda mais próxima de `local_point`
## num topo retangular de meias medidas `half_size` (X e Z). No centro exato, empurra para +X.
static func edge_direction(local_point: Vector2, half_size: Vector2) -> Vector2:
	var to_x_edge: float = half_size.x - absf(local_point.x)
	var to_z_edge: float = half_size.y - absf(local_point.y)
	if to_x_edge <= to_z_edge:
		return Vector2(_side(local_point.x), 0.0)
	return Vector2(0.0, _side(local_point.y))


## Devolve a velocidade horizontal desejada somando `push` a `input_velocity`, depois de tirar da
## entrada a parte que vai contra o empurrão: andar contra ele não segura ninguém no topo, e
## andar de lado continua livre.
static func steer(input_velocity: Vector3, push: Vector3) -> Vector3:
	if push.is_zero_approx():
		return input_velocity
	var push_direction: Vector3 = push.normalized()
	var along: float = input_velocity.dot(push_direction)
	if along < 0.0:
		input_velocity -= push_direction * along
	return input_velocity + push


## Devolve o lado (1 ou -1) de uma coordenada; zero conta como positivo.
static func _side(coordinate: float) -> float:
	return -1.0 if coordinate < 0.0 else 1.0
