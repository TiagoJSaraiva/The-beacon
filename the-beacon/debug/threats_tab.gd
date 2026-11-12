class_name ThreatsTab
extends DebugTab
## Aba "Ameaças" do painel de debug: barcos, Afogado e carrancas sob demanda.

## Distância à frente do jogador em que a carranca invocada aparece (fora do alcance do pulo).
const FIGUREHEAD_DISTANCE := 4.0
const LEVEL_STEP := 0.05

var _boats: BoatDirector
var _drowned: DrownedDirector
var _figurehead: FigureheadDirector


## Monta a aba para os três diretores.
func setup(boats: BoatDirector, drowned: DrownedDirector, figurehead: FigureheadDirector) -> void:
	_boats = boats
	_drowned = drowned
	_figurehead = figurehead
	add_title("Barcos")
	add_buttons({"Spawnar barco (sem limite)": _spawn_boat, "Afundar todos": _boats.sink_all})
	add_title("Afogado")
	add_buttons(
		{
			"+1 ponto": _drowned.add_drowned_point,
			"Forçar entrada": _drowned.force_enter,
			"Remover Afogado": _drowned.remove_drowned,
		}
	)
	add_value_action(
		"Aproximação (0–1)",
		0.0,
		1.0,
		LEVEL_STEP,
		drowned.approach.level,
		"Definir",
		func(value: float) -> void: _drowned.approach.level = value
	)
	add_title("Carranca")
	add_buttons(
		{
			"Invocar à frente": _spawn_figurehead,
			"Dissolver todas": _figurehead.dissolve_all,
			"Zerar cegueiras": func() -> void: _figurehead.tracker.blinds = 0,
		}
	)
	add_status()


## Devolve barcos na rota, pontos e aproximação do Afogado e carrancas ativas.
func readout() -> String:
	if _boats == null:
		return ""
	var progress := PackedStringArray()
	for boat: Boat in _boats.active_boats():
		progress.append("%d%%" % roundi(boat.passage.progress * 100.0))
	var boats_line: String = "Barcos: %d" % progress.size()
	if not progress.is_empty():
		boats_line += " (%s)" % ", ".join(progress)
	var drowned_line: String = (
		"Afogado: %d ponto(s), aproximação %.2f, %s · carrancas %d, cegueiras %d"
		% [
			_drowned.drowned_points,
			_drowned.approach.level,
			"dentro" if _drowned.has_drowned_inside() else "fora",
			_figurehead.active_count(),
			_figurehead.tracker.blinds,
		]
	)
	return boats_line + "\n" + drowned_line


## Cria um barco no início da rota mesmo acima do limite simultâneo.
func _spawn_boat() -> void:
	if _boats.boat_path == null:
		show_status("Sem rota de barcos nesta cena.")
		return
	_boats.spawn()
	show_status("Barco criado no início da rota.")


## Invoca uma carranca à frente do jogador.
func _spawn_figurehead() -> void:
	_figurehead.spawn_in_front_of_player(FIGUREHEAD_DISTANCE)
	show_status("Carranca invocada a %.0f m à frente." % FIGUREHEAD_DISTANCE)
