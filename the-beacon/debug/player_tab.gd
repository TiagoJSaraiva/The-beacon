class_name PlayerTab
extends DebugTab
## Aba "Jogador" do painel de debug: invulnerabilidade, bateria da lanterna, bloqueio da corrida e
## teleporte para pontos do farol.

## Altura acima da navmesh em que o jogador aparece, para não nascer dentro do piso.
const TELEPORT_LIFT := 0.1
## Altura acima do alçapão em que se procura o piso de cima, ao lado do buraco.
const TRAPDOOR_LOOKUP := 0.5
const PERCENT := 100.0

var _player: Player
var _lighthouse: Lighthouse


## Monta a aba para o jogador e o farol dados.
func setup(player: Player, lighthouse: Lighthouse) -> void:
	_player = player
	_lighthouse = lighthouse
	add_toggle(
		"Invulnerável", player.invulnerable, func(on: bool) -> void: _player.invulnerable = on
	)
	add_toggle(
		"Bateria infinita",
		player.flashlight.battery.infinite,
		func(on: bool) -> void: _player.flashlight.battery.infinite = on
	)
	add_buttons(
		{"Encher bateria": _fill_battery, "Tirar bloqueio da corrida": _player.clear_sprint_block}
	)
	add_title("Teleporte")
	add_buttons(
		{
			"Porta (dentro)": _teleport_near.bind(_lighthouse.drowned_entry_point()),
			"Embaixo do alçapão": _teleport_to_trapdoor_below,
			"Casa de máquinas": _teleport_to_node.bind(_lighthouse.machine_house),
			"Alçapão (em cima)": _teleport_to_trapdoor_above,
			"Cabine (cadeira)": _teleport_to_node.bind(_lighthouse.chair),
		}
	)
	add_status()


## Devolve a posição, a bateria e os estados do jogador.
func readout() -> String:
	if _player == null:
		return ""
	var feet: Vector3 = _player.global_position
	return (
		"Jogador: (%.1f, %.1f, %.1f) · bateria %d%%%s%s"
		% [
			feet.x,
			feet.y,
			feet.z,
			roundi(_player.flashlight.battery.ratio() * PERCENT),
			" · invulnerável" if _player.invulnerable else "",
			" · corrida bloqueada" if _player.is_sprint_blocked() else "",
		]
	)


## Enche a bateria; a lanterna apaga e volta a ligar com a tecla dela.
func _fill_battery() -> void:
	_player.flashlight.set_battery_seconds(_player.flashlight.battery.capacity_seconds)
	show_status("Bateria cheia (a lanterna apagou).")


## Teleporta para o ponto da navmesh mais perto de `target`.
func _teleport_near(target: Vector3) -> void:
	var map: RID = _player.get_world_3d().navigation_map
	var point: Vector3 = NavigationServer3D.map_get_closest_point(map, target)
	_player.teleport(point + Vector3.UP * TELEPORT_LIFT)
	show_status("Teleportado para (%.1f, %.1f, %.1f)." % [point.x, point.y, point.z])


## Teleporta para perto do nó.
func _teleport_to_node(node: Node3D) -> void:
	_teleport_near(node.global_position)


## Teleporta para o ponto onde o Afogado bate no alçapão, no térreo.
func _teleport_to_trapdoor_below() -> void:
	_teleport_near(_lighthouse.drowned_targets()[DrownedBrain.Target.TRAPDOOR_BELOW])


## Teleporta para o piso de cima, ao lado do alçapão.
func _teleport_to_trapdoor_above() -> void:
	_teleport_near(_lighthouse.trapdoor.global_position + Vector3.UP * TRAPDOOR_LOOKUP)
