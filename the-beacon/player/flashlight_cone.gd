class_name FlashlightCone
extends RefCounted
## Geometria do cone da lanterna, sem checar obstáculos.


static func contains(
	origin: Vector3, forward: Vector3, point: Vector3, max_range: float, half_angle_degrees: float
) -> bool:
	var to_point: Vector3 = point - origin
	var distance: float = to_point.length()
	if distance > max_range:
		return false
	if distance <= 0.0001:
		return true
	return forward.normalized().angle_to(to_point) <= deg_to_rad(half_angle_degrees)
