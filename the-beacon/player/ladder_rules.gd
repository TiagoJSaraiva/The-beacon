class_name LadderRules
extends RefCounted
## Regras da escada de mão do jogador: sentido da subida, velocidade vertical e o que sobra do
## movimento horizontal de quem está agarrado.


## Devolve o sentido da subida, de -1 (desce) a 1 (sobe), a partir do eixo frente/trás do input
## (`move_y`, negativo para a frente, como em `Input.get_vector`) e da inclinação do olhar
## (`pitch`, em radianos, negativa olhando para baixo). Olhando para baixo além de
## `descend_pitch`, a frente desce e trás sobe: assim se desce vindo do piso de cima.
static func climb_direction(move_y: float, pitch: float, descend_pitch: float) -> float:
	var forward: float = -move_y
	if pitch < -descend_pitch:
		return -forward
	return forward


## Devolve a velocidade vertical em m/s para o sentido dado. Não sobe com os pés em
## `top_height` ou acima (quem segue em frente sai para o piso) nem com `leaving` ligado
## (no chão, andando para longe da escada); descer continua livre.
static func vertical_speed(
	direction: float, climb_speed: float, feet_height: float, top_height: float, leaving: bool
) -> float:
	if direction > 0.0 and (feet_height >= top_height or leaving):
		return 0.0
	return direction * climb_speed


## Devolve o movimento horizontal sem a parte que se afasta da escada (`away`, normalizado).
## A parte em direção à escada e a lateral ficam.
static func without_away(horizontal: Vector3, away: Vector3) -> Vector3:
	var outward: float = horizontal.dot(away)
	if outward <= 0.0:
		return horizontal
	return horizontal - away * outward
