class_name SeatRules
extends RefCounted
## Limite do olhar de quem está sentado (puro).


## Mantém `yaw` a no máximo `limit` radianos de `center`, para qualquer lado e pelo menor
## ângulo, mesmo depois de várias voltas.
static func clamp_yaw(yaw: float, center: float, limit: float) -> float:
	return center + clampf(angle_difference(center, yaw), -limit, limit)
