class_name ThreatRules
extends RefCounted
## Nível de ameaça e sorteios dos Afogados (GDD 1.2.10).


## Sobe com cada barco afundado e enquanto a porta está quebrada.
static func threat_level(drowned_points: int, door_broken: bool, config: ThreatConfig) -> float:
	var door: float = config.threat_from_broken_door if door_broken else 0.0
	return drowned_points * config.threat_per_drowned_point + door


static func spawn_chance(threat: float, config: ThreatConfig) -> float:
	return clampf(config.spawn_chance_base + config.spawn_chance_per_threat * threat, 0.0, 1.0)


## Quantos aparecem juntos: cada extra tem chance proporcional à ameaça.
static func spawn_count(
	threat: float, max_count: int, config: ThreatConfig, rng: RandomNumberGenerator
) -> int:
	var extra_chance: float = clampf(config.extra_drowned_chance_per_threat * threat, 0.0, 1.0)
	var count: int = 1
	while count < max_count and rng.randf() < extra_chance:
		count += 1
	return mini(count, max_count)


## Sabotagem mais grave (gerador) fica mais provável com a ameaça; senão, a mangueira.
static func prefers_generator(
	threat: float, config: ThreatConfig, rng: RandomNumberGenerator
) -> bool:
	var severe_weight: float = config.severe_action_weight_per_threat * threat
	return rng.randf() < severe_weight / (1.0 + severe_weight)
