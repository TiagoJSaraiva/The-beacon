class_name SpiralStepLayout
extends RefCounted
## Regras puras da divisão da escada em caracol em degraus soltos: quantos são e que trecho do
## caracol (em progresso, 0 = base, 1 = topo) cada um ocupa.


## Devolve quantos degraus cabem na altura `rise` com degraus de cerca de `step_rise`, no mínimo
## um.
static func step_count(rise: float, step_rise: float) -> int:
	if step_rise <= 0.0:
		return 1
	return maxi(roundi(rise / step_rise), 1)


## Devolve o trecho (início, fim) do degrau `index` de `count`, em progresso. Cada degrau ocupa a
## fração `fill` (0 a 1) da sua fatia, centrado nela; o resto vira vão entre os degraus.
static func step_range(index: int, count: int, fill: float) -> Vector2:
	var slice: float = 1.0 / count
	var center: float = (index + 0.5) * slice
	var half: float = slice * clampf(fill, 0.0, 1.0) * 0.5
	return Vector2(center - half, center + half)


## Devolve o progresso do meio do degrau `index` de `count`, onde a face de cima dele encontra a
## rampa de colisão.
static func step_center(index: int, count: int) -> float:
	return (index + 0.5) / count
