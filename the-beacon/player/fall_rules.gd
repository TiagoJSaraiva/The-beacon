class_name FallRules
extends RefCounted
## Consequência de uma queda pela altura (GDD 1.2.15): nada, lentidão ou morte.

enum Outcome { NONE, SLOW, FATAL }


static func evaluate(height: float, config: FallConfig) -> Outcome:
	if height >= config.fatal_height:
		return Outcome.FATAL
	if height >= config.slow_height:
		return Outcome.SLOW
	return Outcome.NONE
