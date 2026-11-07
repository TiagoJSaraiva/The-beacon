class_name FallRules
extends RefCounted
## Consequência de uma queda pela altura (GDD 1.2.15): nada, corrida bloqueada ou morte.

enum Outcome { NONE, SPRINT_BLOCK, FATAL }


## Devolve a consequência de uma queda desta altura, em metros. Cada limite já vale na altura
## exata.
static func evaluate(height: float, config: FallConfig) -> Outcome:
	if height >= config.fatal_height:
		return Outcome.FATAL
	if height >= config.sprint_block_height:
		return Outcome.SPRINT_BLOCK
	return Outcome.NONE
