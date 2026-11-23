class_name FullbrightView
extends RefCounted
## "Sem escuridão" do painel de debug: troca o `Environment` do mundo por uma cópia com luz
## ambiente branca forte, para inspecionar a cena. Usa uma cópia porque o original é sub-recurso de
## `game.tscn`, que pode ser compartilhado entre recargas da cena; desligar devolve o original.

const AMBIENT_COLOR := Color.WHITE
const AMBIENT_ENERGY := 1.2

var active: bool = false

var _world_environment: WorldEnvironment
var _original: Environment


## Guarda o `WorldEnvironment` cujo `Environment` será trocado.
func _init(world_environment: WorldEnvironment) -> void:
	_world_environment = world_environment


## Liga ou desliga a luz ambiente forte. Sem `WorldEnvironment`, não faz nada.
func set_active(on: bool) -> void:
	if _world_environment == null or on == active:
		return
	active = on
	if on:
		_original = _world_environment.environment
		var bright: Environment = _original.duplicate()
		bright.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		bright.ambient_light_color = AMBIENT_COLOR
		bright.ambient_light_energy = AMBIENT_ENERGY
		_world_environment.environment = bright
	else:
		_world_environment.environment = _original
		_original = null
