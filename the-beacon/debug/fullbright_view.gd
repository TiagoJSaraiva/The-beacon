class_name FullbrightView
extends RefCounted
## "Sem escuridão" do painel de debug: troca o `Environment` da câmera do jogador por uma cópia com
## luz ambiente branca forte, para inspecionar a cena. Usa uma cópia porque o original é um recurso
## compartilhado (`player/interior_environment.tres`); desligar devolve o original.

const AMBIENT_COLOR := Color.WHITE
const AMBIENT_ENERGY := 1.2

var active: bool = false

var _camera: Camera3D
var _original: Environment


## Guarda a câmera cujo `Environment` será trocado.
func _init(camera: Camera3D) -> void:
	_camera = camera


## Liga ou desliga a luz ambiente forte. Sem câmera ou sem `Environment` nela, não faz nada.
func set_active(on: bool) -> void:
	if _camera == null or on == active:
		return
	if on and _camera.environment == null:
		return
	active = on
	if on:
		_original = _camera.environment
		var bright: Environment = _original.duplicate()
		bright.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		bright.ambient_light_color = AMBIENT_COLOR
		bright.ambient_light_energy = AMBIENT_ENERGY
		_camera.environment = bright
	else:
		_camera.environment = _original
		_original = null
