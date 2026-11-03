class_name FigureheadSpawnRules
extends RefCounted
## Onde uma carranca pode surgir (puro): só nas áreas do farol tomadas pelo nevoeiro, fora
## do campo de visão do jogador e longe dele, para os pontos não serem decoráveis.

enum Area { GROUND_FLOOR, STAIRS, CABIN }


## Área pela altura do ponto; os limites vêm da geometria do farol.
static func area_for_height(height: float, stairs_from: float, cabin_from: float) -> Area:
	if height >= cabin_from:
		return Area.CABIN
	if height >= stairs_from:
		return Area.STAIRS
	return Area.GROUND_FLOOR


static func is_fogged(area: Area, stage: FogStage.Stage) -> bool:
	match area:
		Area.GROUND_FLOOR:
			return stage >= FogStage.Stage.GROUND_FLOOR
		Area.STAIRS:
			return stage >= FogStage.Stage.STAIRS
		Area.CABIN:
			return stage >= FogStage.Stage.CABIN
	return false


## Longe do olho e fora do cone de visão (ângulo a partir da direção do olhar).
static func is_hidden_and_far(
	point: Vector3,
	eye: Vector3,
	forward: Vector3,
	view_half_angle_degrees: float,
	min_distance: float
) -> bool:
	var to_point: Vector3 = point - eye
	if to_point.length() < min_distance:
		return false
	return rad_to_deg(forward.angle_to(to_point)) > view_half_angle_degrees
