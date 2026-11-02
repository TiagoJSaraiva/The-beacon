class_name RunSnapshot
extends Node
## Junta e restaura o estado exato da partida no meio da noite (GDD 1.2.22): horário,
## sistemas, recursos, ameaças em andamento, tutorial e posição do jogador. Cada sistema é
## dono do próprio to_dict/from_dict (decisão 0008); aqui só se decide o que entra e a ordem.

@export var night: NightDirector
@export var events: EventDirector
@export var lighthouse: Lighthouse
@export var player: Player
@export var fog: FogSystem
@export var boats: BoatDirector
@export var drowned: DrownedDirector
@export var fog_man: FogManDirector
@export var tutorial: TutorialDirector


## Dificuldade do save, para quem precisa escolhê-la antes de restaurar.
static func difficulty_id_of(saved: Dictionary) -> StringName:
	var run_data: Dictionary = saved.get("run", {})
	return StringName(str(run_data.get("difficulty_id", "")))


func capture(run: RunState) -> Dictionary:
	return {
		"run": run.to_dict(),
		"night": night.to_dict(),
		"events": events.to_dict(),
		"lighthouse": lighthouse.to_dict(),
		"player": player.to_dict(),
		"fog": fog.to_dict(),
		"boats": boats.to_dict(),
		"drowned": drowned.to_dict(),
		"fog_man": fog_man.to_dict(),
		"tutorial": tutorial.to_dict(),
	}


## O farol vem antes do jogador (o galão na mão vem do suporte) e dos Afogados (que leem
## porta e alçapão); o nevoeiro vem antes do barco e do Homem de Nevoeiro, que dependem dele.
func restore(saved: Dictionary, run: RunState) -> void:
	run.from_dict(saved.get("run", {}))
	night.from_dict(saved.get("night", {}))
	events.from_dict(saved.get("events", {}))
	lighthouse.from_dict(saved.get("lighthouse", {}))
	player.from_dict(saved.get("player", {}))
	fog.from_dict(saved.get("fog", {}))
	boats.from_dict(saved.get("boats", {}))
	drowned.from_dict(saved.get("drowned", {}))
	fog_man.from_dict(saved.get("fog_man", {}))
	tutorial.from_dict(saved.get("tutorial", {}))
