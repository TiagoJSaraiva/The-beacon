class_name PerceptionRules
extends RefCounted
## Alcance do Afogado (GDD 1.2.10): distância real, com cada obstáculo entre ele e o
## jogador somando uma penalidade. Não é simplesmente estar no mesmo andar.


## Devolve a distância real somada à penalidade de cada obstáculo.
static func effective_distance(distance: float, occluders: int, config: DrownedConfig) -> float:
	return distance + occluders * config.occlusion_penalty


## Diz se a distância efetiva cabe em `perception_range`.
static func is_in_reach(distance: float, occluders: int, config: DrownedConfig) -> bool:
	return effective_distance(distance, occluders, config) <= config.perception_range
