class_name FogStage
extends RefCounted
## Estágios do nevoeiro pelo avanço (0 a 1), com os limiares do `FogConfig`.

enum Stage { NONE, SEA, NEAR, GROUND_FLOOR, STAIRS, TRAPDOOR, CABIN }


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


## Perto do farol o nevoeiro cobre a cabeça do farol: o feixe não sai.
static func blocks_beam(stage: Stage) -> bool:
	return stage >= Stage.NEAR


## Dentro do farol: Afogado se aproximando, mangueira estourada, carrancas.
static func is_inside(stage: Stage) -> bool:
	return stage >= Stage.GROUND_FLOOR
