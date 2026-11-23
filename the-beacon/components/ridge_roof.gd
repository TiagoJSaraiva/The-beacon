class_name RidgeRoof
extends RefCounted
## Geometria de um telhado de duas águas (regra pura): um prisma triangular com a cumeeira ao longo
## de X local. Posto em cima de uma máquina numa camada própria, ele deixa o topo inclinado demais
## para o jogador ficar de pé ou um objeto parar ali: os dois escorregam.


## Devolve os 6 vértices de um prisma com a base em `base_y` (de -half_width a half_width em Z)
## e a cumeeira em `apex_y`, de -half_length a half_length em X.
static func prism(
	half_width: float, half_length: float, base_y: float, apex_y: float
) -> PackedVector3Array:
	var points := PackedVector3Array()
	for x: float in [-half_length, half_length]:
		points.append(Vector3(x, base_y, -half_width))
		points.append(Vector3(x, base_y, half_width))
		points.append(Vector3(x, apex_y, 0.0))
	return points


## Devolve o telhado sobre o topo de uma caixa de `size_x` por `size_z`, com a base em y=0 e as
## águas inclinadas `angle_degrees`. A cumeeira segue o lado mais comprido, para o telhado ficar
## mais baixo.
static func over_box_top(size_x: float, size_z: float, angle_degrees: float) -> PackedVector3Array:
	var along_x: bool = size_x >= size_z
	var half_width: float = (size_z if along_x else size_x) * 0.5
	var half_length: float = (size_x if along_x else size_z) * 0.5
	var rise: float = half_width * tan(deg_to_rad(angle_degrees))
	var points: PackedVector3Array = prism(half_width, half_length, 0.0, rise)
	if along_x:
		return points
	var turned := PackedVector3Array()
	for point: Vector3 in points:
		turned.append(Vector3(point.z, point.y, point.x))
	return turned
