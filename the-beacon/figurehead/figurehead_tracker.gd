class_name FigureheadTracker
extends RefCounted
## Regras das carrancas na noite (entrega 2): quantas podem existir, quando voltam a surgir,
## o que cada ataque faz e quando a lanterna as dissolve.
## Uma carranca destruída ou que atacou ocupa a vaga até o seu tempo de volta passar; a que
## some porque o nevoeiro recuou libera a vaga na hora.

enum Attack { BLIND, KNOCKDOWN }

var config: FigureheadConfig
var blinds: int = 0

var _respawn_timers: Array[float] = []
var _spawn_gap_left: float = 0.0


func _init(figurehead_config: FigureheadConfig) -> void:
	config = figurehead_config


func tick(delta: float) -> void:
	_spawn_gap_left = maxf(0.0, _spawn_gap_left - delta)
	for index: int in range(_respawn_timers.size() - 1, -1, -1):
		_respawn_timers[index] -= delta
		if _respawn_timers[index] <= 0.0:
			_respawn_timers.remove_at(index)


func can_spawn(active_count: int) -> bool:
	var occupied: int = active_count + _respawn_timers.size()
	return occupied < config.max_simultaneous and _spawn_gap_left <= 0.0


func on_spawned() -> void:
	_spawn_gap_left = config.spawn_interval_seconds


func on_destroyed() -> void:
	_respawn_timers.append(config.respawn_after_destroyed_seconds)


## Depois de `blinds_before_knockdown` cegueiras, o ataque seguinte derruba e a contagem
## recomeça.
func on_attacked() -> Attack:
	_respawn_timers.append(config.respawn_after_attack_seconds)
	if blinds >= config.blinds_before_knockdown:
		blinds = 0
		return Attack.KNOCKDOWN
	blinds += 1
	return Attack.BLIND


func is_dissolved(lit_seconds: float) -> bool:
	return lit_seconds >= config.dissolve_seconds
