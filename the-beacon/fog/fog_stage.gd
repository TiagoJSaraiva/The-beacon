class_name FogStage
extends RefCounted
## Estágios do nevoeiro pelo avanço (0 a 1), com os limiares do `FogConfig`.

enum Stage { NONE, SEA, NEAR, GROUND_FLOOR, STAIRS, TRAPDOOR, CABIN }


## Devolve o estágio do avanço: zero é NONE, e cada estágio começa no limiar dele.
static func for_advance(advance: float, config: FogConfig) -> Stage:
	if advance <= 0.0:
		return Stage.NONE
	if advance >= config.cabin_advance:
		return Stage.CABIN
	if advance >= config.trapdoor_advance:
		return Stage.TRAPDOOR
	if advance >= config.stairs_advance:
		return Stage.STAIRS
	if advance >= config.ground_floor_advance:
		return Stage.GROUND_FLOOR
	if advance >= config.near_advance:
		return Stage.NEAR
	return Stage.SEA


## Diz se o estágio bloqueia o feixe: perto do farol, o nevoeiro cobre a cabeça e a luz não sai.
static func blocks_beam(stage: Stage) -> bool:
	return stage >= Stage.NEAR


## Diz se o nevoeiro já está dentro do farol, o que aproxima o Afogado, estoura a mangueira e
## libera as carrancas.
static func is_inside(stage: Stage) -> bool:
	return stage >= Stage.GROUND_FLOOR
