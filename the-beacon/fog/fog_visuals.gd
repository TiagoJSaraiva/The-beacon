class_name FogVisuals
extends Node3D
## Nevoeiro visível (entrega 2), por névoa volumétrica (decisão 0025): uma faixa no trecho coberto
## da rota dos barcos, um anel em volta do farol a partir de NEAR (só na câmera da porta: a camada
## de render dele fica fora das outras câmeras), um volume por área interna e um em volta da
## cabeça do farol no estágio BEAM. Cada volume esmaece ao entrar e sair do seu estágio. Lê o
## estado do FogSystem a cada frame.
## Teste (branch teste/nevoeiro-shader-e-volume): cada volume tem um filho `ShaderLayer`, uma malha
## com o shader antigo (`fog_volume.gdshader`), que esmaece junto. As duas camadas somam; a
## densidade de cada uma é multiplicada por `volume_density_scale` e `shader_density_scale`.

@export var fade_per_second: float = 0.5
## Meia-altura da faixa no mar no crescimento máximo (NEAR): passa do topo da imagem das câmeras
## do mar (`test/scenes/sea_cameras_test.gd`).
@export var sea_band_half_height: float = 60.0
## Limite da meia-profundidade da faixa; o comprimento vem do trecho da rota.
@export var sea_band_half_depth: float = 45.0
## Menor meia-medida da faixa: tamanho zero deixaria o volume degenerado.
@export var sea_band_min_half_extent: float = 0.5
## Multiplica a densidade dos `FogVolume` (0 desliga a névoa volumétrica).
@export_range(0.0, 2.0, 0.05) var volume_density_scale: float = 1.0
## Multiplica a densidade das camadas de shader (0 desliga o shader).
@export_range(0.0, 2.0, 0.05) var shader_density_scale: float = 1.0

var _fog: FogSystem
var _boat_path: Path3D
var _stage_volumes: Dictionary[FogVolume, FogStage.Stage] = {}
## Densidade de cada volume com opacidade total, lida do material da cena.
var _full_density: Dictionary[FogVolume, float] = {}
## Opacidade atual de cada volume, de 0 a 1.
var _opacity: Dictionary[FogVolume, float] = {}
var _sea_band_shape: SeaBandShape
## Camada de shader de cada volume, com material próprio, e a densidade dela na cena.
var _shader_layers: Dictionary[FogVolume, ShaderMaterial] = {}
var _shader_density: Dictionary[FogVolume, float] = {}

@onready var _sea_band: FogVolume = %SeaBand


## Associa cada volume ao estágio em que ele aparece, guarda a densidade de cada um e da camada de
## shader dele, monta a regra de tamanho da faixa e começa com todos invisíveis.
func _ready() -> void:
	_sea_band_shape = sea_band_shape()
	_stage_volumes = {
		%NearRing: FogStage.Stage.NEAR,
		%GroundFloor: FogStage.Stage.GROUND_FLOOR,
		%Stairs: FogStage.Stage.STAIRS,
		%Cabin: FogStage.Stage.CABIN,
		%LampShroud: FogStage.Stage.BEAM,
	}
	for volume: FogVolume in _all_volumes():
		_full_density[volume] = (volume.material as FogMaterial).density
		_take_shader_layer(volume)
		_set_opacity(volume, 0.0)


## Esmaece cada volume conforme o estágio atual e posiciona a faixa no mar sobre o trecho da
## rota.
func _process(delta: float) -> void:
	if _fog == null:
		return
	var state: FogState = _fog.state
	var stage: FogStage.Stage = state.stage()
	for volume: FogVolume in _stage_volumes:
		_fade(volume, 1.0 if stage >= _stage_volumes[volume] else 0.0, delta)
	var route: Vector2 = state.route_segment()
	var has_route_fog: bool = route.y > route.x
	# Mais denso e mais alto à medida que avança, até o máximo em NEAR.
	var growth: float = clampf(state.advance / state.config.near_advance, 0.0, 1.0)
	if has_route_fog:
		_place_sea_band(route, growth)
	_fade(_sea_band, growth if has_route_fog else 0.0, delta)


## Recebe o sistema de nevoeiro e a rota dos barcos. Antes disso, nada é atualizado.
func setup(fog: FogSystem, boat_path: Path3D) -> void:
	_fog = fog
	_boat_path = boat_path


## Devolve a regra de tamanho da faixa no mar com os limites deste nó.
func sea_band_shape() -> SeaBandShape:
	var shape := SeaBandShape.new()
	shape.max_half_height = sea_band_half_height
	shape.max_half_depth = sea_band_half_depth
	shape.min_half_extent = sea_band_min_half_extent
	return shape


## Posiciona, orienta e dimensiona a faixa sobre o trecho da rota (início, fim, em fração),
## conforme o crescimento do nevoeiro (0 a 1). O centro fica no nível da rota, onde a faixa é
## mais densa.
func _place_sea_band(route: Vector2, growth: float) -> void:
	var curve: Curve3D = _boat_path.curve
	var length: float = curve.get_baked_length()
	var start: Vector3 = _boat_path.to_global(curve.sample_baked(route.x * length))
	var end: Vector3 = _boat_path.to_global(curve.sample_baked(route.y * length))
	var along: Vector3 = end - start
	var x_axis: Vector3 = along.normalized()
	_sea_band.global_transform = Transform3D(
		Basis(x_axis, Vector3.UP, x_axis.cross(Vector3.UP)), (start + end) * 0.5
	)
	_sea_band.size = _sea_band_shape.half_extents(along.length() * 0.5, growth) * 2.0
	# A malha do shader tem lado 2: a escala é a meia-medida.
	var layer := _sea_band.get_node_or_null(^"ShaderLayer") as Node3D
	if layer != null:
		layer.scale = _sea_band.size * 0.5


## Aproxima a opacidade do volume do valor-alvo, na velocidade `fade_per_second`.
func _fade(volume: FogVolume, target: float, delta: float) -> void:
	_set_opacity(volume, move_toward(_opacity[volume], target, fade_per_second * delta))


## Escala a densidade do volume e da camada de shader dele pela opacidade e esconde o volume
## quando ela é zero.
func _set_opacity(volume: FogVolume, opacity: float) -> void:
	_opacity[volume] = opacity
	var material := volume.material as FogMaterial
	material.density = _full_density[volume] * opacity * volume_density_scale
	if _shader_layers.has(volume):
		_shader_layers[volume].set_shader_parameter(&"opacity", opacity)
		_shader_layers[volume].set_shader_parameter(
			&"density", _shader_density[volume] * shader_density_scale
		)
	volume.visible = opacity > 0.0


## Guarda a camada de shader do volume, se houver, com uma cópia do material: o da cena é
## compartilhado entre recargas e não pode levar o estado de uma noite para a outra.
func _take_shader_layer(volume: FogVolume) -> void:
	var layer := volume.get_node_or_null(^"ShaderLayer") as MeshInstance3D
	if layer == null:
		return
	var material := (layer.material_override as ShaderMaterial).duplicate() as ShaderMaterial
	layer.material_override = material
	_shader_layers[volume] = material
	_shader_density[volume] = material.get_shader_parameter(&"density")


## Devolve a faixa no mar e todos os volumes por estágio.
func _all_volumes() -> Array[FogVolume]:
	var volumes: Array[FogVolume] = [_sea_band]
	volumes.append_array(_stage_volumes.keys())
	return volumes
