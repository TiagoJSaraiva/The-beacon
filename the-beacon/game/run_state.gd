class_name RunState
extends RefCounted
## Plantão em andamento: tudo o que passa de uma noite para a outra (decisão 0015). O resto
## da simulação recomeça do zero a cada noite. Vence quem sobrevive à última noite.

var difficulty_id: StringName
var total_nights: int
var current_night: int = 1
## Barcos afundados no plantão; aceleram a chegada do Afogado.
var drowned_points: int = 0
## A mangueira estoura uma vez só e não tem conserto.
var hose_burst: bool = false
## A bateria da lanterna nunca recarrega, nem entre noites.
var flashlight_battery_seconds: float = 0.0
## Passos do tutorial já mostrados, para não repetir nas noites seguintes.
var tutorial_shown_ids: Array[StringName] = []


func _init(difficulty: StringName = &"", nights: int = 1, battery_seconds: float = 0.0) -> void:
	difficulty_id = difficulty
	total_nights = nights
	flashlight_battery_seconds = battery_seconds


## Plantão novo, na primeira noite e com a lanterna carregada.
static func new_run(difficulty: DifficultyConfig) -> RunState:
	return RunState.new(difficulty.id, difficulty.nights, difficulty.flashlight.battery_seconds)


func is_last_night() -> bool:
	return current_night >= total_nights


func advance_night() -> void:
	current_night = mini(current_night + 1, total_nights)


func to_dict() -> Dictionary:
	var shown: Array[String] = []
	for step_id: StringName in tutorial_shown_ids:
		shown.append(String(step_id))
	return {
		"difficulty_id": String(difficulty_id),
		"total_nights": total_nights,
		"current_night": current_night,
		"drowned_points": drowned_points,
		"hose_burst": hose_burst,
		"flashlight_battery_seconds": flashlight_battery_seconds,
		"tutorial_shown_ids": shown,
	}


## O JSON devolve números como float; os inteiros são convertidos aqui.
func from_dict(data: Dictionary) -> void:
	difficulty_id = StringName(str(data.get("difficulty_id", String(difficulty_id))))
	total_nights = maxi(int(data.get("total_nights", total_nights)), 1)
	current_night = clampi(int(data.get("current_night", 1)), 1, total_nights)
	drowned_points = maxi(int(data.get("drowned_points", 0)), 0)
	hose_burst = bool(data.get("hose_burst", false))
	flashlight_battery_seconds = maxf(
		float(data.get("flashlight_battery_seconds", flashlight_battery_seconds)), 0.0
	)
	tutorial_shown_ids.clear()
	var shown: Array = data.get("tutorial_shown_ids", [])
	for value: Variant in shown:
		tutorial_shown_ids.append(StringName(str(value)))
