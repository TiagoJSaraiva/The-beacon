class_name DifficultyConfig
extends Resource
## Uma dificuldade completa: duração do plantão e todos os parâmetros de balanceamento.
## As ameaças são as mesmas em todas as dificuldades; só os valores mudam (GDD 1.2.14).

@export var id: StringName = &""
@export var display_name: String = ""
@export var nights: int = 3
@export var tutorial_enabled: bool = false

@export_group("Eventos")
@export var events: Array[EventDefinition] = []
## Multiplica a chance de todos os eventos sorteáveis.
@export var event_chance_multiplier: float = 1.0
## Aumento da chance a cada noite após a primeira (0.2 = +20% por noite).
@export var chance_increase_per_night: float = 0.0

@export_group("Sistemas")
@export var time: TimeConfig
@export var power: PowerConfig
@export var flashlight: FlashlightConfig
@export var repair: RepairConfig
@export var fog: FogConfig
@export var boat: BoatConfig
@export var threat: ThreatConfig
@export var drowned: DrownedConfig
@export var trapdoor: TrapdoorConfig
@export var fog_man: FogManConfig
@export var fall: FallConfig


## Multiplicador de chance dos eventos na noite indicada (a primeira noite é 1).
func chance_multiplier_for_night(night: int) -> float:
	return event_chance_multiplier * (1.0 + chance_increase_per_night * float(night - 1))


## Lista os problemas de configuração. Vazia quando o recurso está pronto para uso.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id vazio")
	if nights < 1:
		errors.append("nights precisa ser >= 1")
	var sub_configs: Dictionary[String, Resource] = {
		"time": time,
		"power": power,
		"flashlight": flashlight,
		"repair": repair,
		"fog": fog,
		"boat": boat,
		"threat": threat,
		"drowned": drowned,
		"trapdoor": trapdoor,
		"fog_man": fog_man,
		"fall": fall,
	}
	for config_name: String in sub_configs:
		if sub_configs[config_name] == null:
			errors.append("%s não atribuído" % config_name)
	if not errors.is_empty():
		return errors
	if power.generator_start_fuel > power.generator_capacity:
		errors.append("power: combustível inicial do gerador acima da capacidade")
	if power.reserve_start_fuel > power.reserve_capacity:
		errors.append("power: combustível inicial da reserva acima da capacidade")
	if fog.min_intensity > fog.max_intensity:
		errors.append("fog: intensidade mínima acima da máxima")
	if fall.slow_height >= fall.fatal_height:
		errors.append("fall: altura de lentidão precisa ser menor que a fatal")
	if boat.sink_seconds_at_max_intensity > boat.sink_seconds_at_min_intensity:
		errors.append("boat: nevoeiro forte precisa afundar mais rápido que o fraco")
	for event: EventDefinition in events:
		if event == null or event.id == &"":
			errors.append("evento nulo ou sem id")
	return errors
