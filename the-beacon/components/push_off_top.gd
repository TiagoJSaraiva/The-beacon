class_name PushOffTop
extends Node3D
## Marca o topo de uma máquina de onde o jogador e os props são empurrados para a borda mais
## próxima, para não pararem em cima dela. Serve onde o telhado invisível (`SlipperyRoof`) não
## cabe, como embaixo da escada em caracol. Fica filho do corpo da máquina, no centro do topo, com
## X e Z alinhados às bordas; quem pisa no corpo procura o marcador nele.

## Inclinação máxima do apoio de um corpo rígido que conta como estar em cima (a mesma do chão
## do jogador).
const MAX_SUPPORT_ANGLE_DEGREES := 45.0
## Distância da sondagem para baixo que acha o piso sob o personagem, em metros.
const FLOOR_PROBE_DEPTH := 0.05

## Largura (X) e profundidade (Z) do topo.
@export var top_size: Vector2 = Vector2.ONE
## Velocidade horizontal do empurrão, em m/s.
@export var push_speed: float = 2.0


## Devolve o empurrão (m/s, horizontal) para um personagem no chão sobre um corpo marcado, com
## uma sondagem curta da própria forma para baixo: parado, o `move_and_slide` não reporta colisão
## com o piso. Zero se ele não estiver no chão ou o chão não tiver marcador.
static func push_under(character: CharacterBody3D) -> Vector3:
	if not character.is_on_floor():
		return Vector3.ZERO
	var hit := KinematicCollision3D.new()
	var probe: Vector3 = -character.up_direction * FLOOR_PROBE_DEPTH
	if not character.test_move(character.global_transform, probe, hit):
		return Vector3.ZERO
	var marker: PushOffTop = find_on(hit.get_collider())
	if marker == null:
		return Vector3.ZERO
	return marker.push_velocity_at(character.global_position)


## Devolve o empurrão (m/s, horizontal) para um corpo rígido apoiado num corpo marcado, pelos
## contatos do passo de física. O corpo precisa reportar contatos (`contact_monitor` e
## `max_contacts_reported`). Contatos de lado não contam: só o apoio por baixo, até
## `MAX_SUPPORT_ANGLE_DEGREES`.
static func push_from_contacts(state: PhysicsDirectBodyState3D) -> Vector3:
	for index: int in state.get_contact_count():
		if (
			state.get_contact_local_normal(index).dot(Vector3.UP)
			< cos(deg_to_rad(MAX_SUPPORT_ANGLE_DEGREES))
		):
			continue
		var marker: PushOffTop = find_on(state.get_contact_collider_object(index))
		if marker != null:
			return marker.push_velocity_at(state.transform.origin)
	return Vector3.ZERO


## Devolve o marcador filho de `body`, ou null se ele não tiver um.
static func find_on(body: Object) -> PushOffTop:
	var node := body as Node
	if node == null:
		return null
	for child: Node in node.get_children():
		var marker := child as PushOffTop
		if marker != null:
			return marker
	return null


## Devolve o empurrão (m/s, horizontal) para quem está em `point` (global): `push_speed` na
## direção da borda mais próxima do topo.
func push_velocity_at(point: Vector3) -> Vector3:
	var local: Vector3 = to_local(point)
	var edge: Vector2 = PushOffRules.edge_direction(Vector2(local.x, local.z), top_size * 0.5)
	var direction: Vector3 = global_basis * Vector3(edge.x, 0.0, edge.y)
	direction.y = 0.0
	return direction.normalized() * push_speed
