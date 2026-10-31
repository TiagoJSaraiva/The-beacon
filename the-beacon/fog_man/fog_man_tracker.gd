class_name FogManTracker
extends RefCounted
## Regras do Homem de Nevoeiro (GDD 1.2.10): surge com o nevoeiro cobrindo a câmera do farol,
## respeitando um intervalo mínimo entre aparições; some ao ficar sob a lanterna por um
## tempo contínuo ou depois de cegar o jogador.

var config: FogManConfig
var cooldown_remaining: float = 0.0
var lit_seconds: float = 0.0


func _init(fog_man_config: FogManConfig) -> void:
	config = fog_man_config


func tick_cooldown(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func can_spawn(fog_covers_camera: bool, already_active: bool) -> bool:
	return fog_covers_camera and not already_active and cooldown_remaining <= 0.0


## Acumula o tempo sob a luz (zera se a luz sair dele) e diz se ele se dissipou.
func update_light(delta: float, lit: bool) -> bool:
	lit_seconds = lit_seconds + delta if lit else 0.0
	return lit_seconds >= config.dissipate_seconds


func on_vanished() -> void:
	cooldown_remaining = config.spawn_cooldown_seconds
	lit_seconds = 0.0


func to_dict() -> Dictionary:
	return {"cooldown_remaining": cooldown_remaining, "lit_seconds": lit_seconds}


func from_dict(data: Dictionary) -> void:
	cooldown_remaining = data.get("cooldown_remaining", 0.0)
	lit_seconds = data.get("lit_seconds", 0.0)
