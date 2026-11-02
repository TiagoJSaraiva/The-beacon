class_name SaveCodec
extends RefCounted
## Conversões de tipos do Godot para o JSON do save (decisão 0011).


static func vector3_to_array(vector: Vector3) -> Array[float]:
	return [vector.x, vector.y, vector.z]


## Lista inválida (save antigo ou editado) vira Vector3.ZERO.
static func array_to_vector3(values: Variant) -> Vector3:
	if not values is Array or values.size() < 3:
		return Vector3.ZERO
	return Vector3(values[0], values[1], values[2])
