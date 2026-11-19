class_name LadderTraversal
extends RefCounted
## Percurso do Afogado por uma escada de mão (um link da navmesh), da entrada à saída. Sobe na
## vertical acima do ponto mais baixo e anda na horizontal no nível do mais alto (ao descer, o
## contrário), para não cortar a borda do piso. Subindo, se a passagem fechar, volta para a
## entrada.

var _entry: Vector3
var _corner: Vector3
var _exit: Vector3
var _going_up: bool = false
var _distance: float = 0.0


## Monta o percurso entre os pontos globais de entrada e saída do link.
func _init(entry: Vector3, exit: Vector3) -> void:
	_entry = entry
	_exit = exit
	_going_up = exit.y > entry.y
	var low: Vector3 = entry if _going_up else exit
	var high: Vector3 = exit if _going_up else entry
	_corner = Vector3(low.x, high.y, low.z)


## Avança `distance` metros e devolve a posição global nova. Subindo com `passage_open`
## desligado, recua a mesma distância em direção à entrada; descendo, segue sempre.
func advance(distance: float, passage_open: bool) -> Vector3:
	var step: float = -distance if _is_blocked(passage_open) else distance
	_distance = clampf(_distance + step, 0.0, _length())
	return position()


## Devolve a posição global atual no percurso.
func position() -> Vector3:
	var first: float = _entry.distance_to(_corner)
	if _distance < first:
		return _entry.lerp(_corner, _distance / first)
	var second: float = _corner.distance_to(_exit)
	if second <= 0.0:
		return _exit
	return _corner.lerp(_exit, (_distance - first) / second)


## Diz se o percurso acabou: chegou à saída ou, subindo com a passagem fechada, voltou à
## entrada.
func is_finished(passage_open: bool) -> bool:
	if _distance >= _length():
		return true
	return _is_blocked(passage_open) and _distance <= 0.0


## Diz se a passagem fechada barra o percurso, o que só vale subindo.
func _is_blocked(passage_open: bool) -> bool:
	return _going_up and not passage_open


## Devolve o comprimento do percurso, em metros.
func _length() -> float:
	return _entry.distance_to(_corner) + _corner.distance_to(_exit)
