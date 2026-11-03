class_name DrownedApproach
extends RefCounted
## Aproximação do Afogado (entrega 2): um medidor de 0 a 1 que sobe enquanto o nevoeiro
## está dentro do farol e há pontos de Afogado, mais rápido com mais pontos, e desce com o
## nevoeiro fora. Cheio, ele entra; só uma vez por noite.

var config: DrownedConfig
var level: float = 0.0
var has_entered: bool = false


func _init(drowned_config: DrownedConfig) -> void:
	config = drowned_config


func rate_per_second(points: int) -> float:
	return config.approach_base_per_second + config.approach_per_point_per_second * points


## Avança o medidor. Devolve true no instante em que o Afogado entra.
func tick(delta: float, fog_inside: bool, points: int) -> bool:
	if has_entered:
		return false
	if fog_inside and points > 0:
		level = minf(1.0, level + rate_per_second(points) * delta)
	else:
		level = maxf(0.0, level - config.approach_recede_per_second * delta)
	if level < 1.0:
		return false
	has_entered = true
	return true
