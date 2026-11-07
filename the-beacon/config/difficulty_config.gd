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
@export var drowned: DrownedConfig
@export var trapdoor: TrapdoorConfig
@export var figurehead: FigureheadConfig
@export var fall: FallConfig


## Devolve o multiplicador de chance dos eventos na noite indicada (a primeira noite é 1).
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
		"drowned": drowned,
		"trapdoor": trapdoor,
		"figurehead": figurehead,
		"fall": fall,
	}
	for config_name: String in sub_configs:
		if sub_configs[config_name] == null:
			errors.append("%s não atribuído" % config_name)
	if not errors.is_empty():
		return errors
	if power.generator_start_fuel > power.generator_capacity:
		errors.append("power: combustível inicial do gerador acima da capacidade")
	errors.append_array(fog.validate())
	if fall.sprint_block_height >= fall.fatal_height:
		errors.append("fall: altura que bloqueia a corrida precisa ser menor que a fatal")
	if boat.crossing_seconds <= 0.0 or boat.max_simultaneous_boats < 1:
		errors.append("boat: travessia precisa de tempo e de ao menos um barco")
	if drowned.approach_base_per_second <= 0.0 or drowned.approach_recede_per_second <= 0.0:
		errors.append("drowned: aproximação precisa subir e descer")
	if trapdoor.resistance_seconds <= 0.0:
		errors.append("trapdoor: resistência precisa ser positiva")
	if figurehead.max_simultaneous < 1:
		errors.append("figurehead: precisa de ao menos uma carranca")
	if figurehead.trigger_range >= figurehead.min_spawn_distance:
		errors.append("figurehead: não pode surgir já ao alcance do pulo")
	if not _ids_are_unique(events):
		errors.append("eventos repetidos")
	for event: EventDefinition in events:
		if event == null or event.id == &"":
			errors.append("evento nulo ou sem id")
	return errors


## Diz se nenhum id se repete na lista. Definições nulas são ignoradas aqui; `validate` as acusa.
static func _ids_are_unique(definitions: Array[EventDefinition]) -> bool:
	var seen: Array[StringName] = []
	for definition: EventDefinition in definitions:
		if definition == null:
			continue
		if seen.has(definition.id):
			return false
		seen.append(definition.id)
	return true
