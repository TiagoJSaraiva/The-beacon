class_name FogVisuals
extends Node3D
## Nevoeiro visível (entrega 2): uma faixa no trecho coberto da rota dos barcos, um anel em
## volta do farol a partir de NEAR (câmera da porta) e um volume por área interna. Cada
## volume esmaece ao entrar e sair do seu estágio. Lê o estado do FogSystem a cada frame.

@export var fade_per_second: float = 0.5
## Metade da altura e da largura da faixa no mar; o comprimento vem do trecho da rota.
@export var sea_band_half_height: float = 8.0
@export var sea_band_half_depth: float = 15.0
## Menor meio-comprimento da faixa: escala zero deixaria o volume degenerado.
@export var sea_band_min_half_length: float = 0.5

var _fog: FogSystem
var _boat_path: Path3D
var _stage_volumes: Dictionary[MeshInstance3D, FogStage.Stage] = {}

@onready var _sea_band: MeshInstance3D = %SeaBand


func _ready() -> void:
	_stage_volumes = {
		%NearRing: FogStage.Stage.NEAR,
		%GroundFloor: FogStage.Stage.GROUND_FLOOR,
		%Stairs: FogStage.Stage.STAIRS,
		%Cabin: FogStage.Stage.CABIN,
	}
	for volume: MeshInstance3D in _all_volumes():
		_set_opacity(volume, 0.0)


func _process(delta: float) -> void:
	if _fog == null:
		return
	var state: FogState = _fog.state
	var stage: FogStage.Stage = state.stage()
	for volume: MeshInstance3D in _stage_volumes:
		_fade(volume, 1.0 if stage >= _stage_volumes[volume] else 0.0, delta)
	var route: Vector2 = state.route_segment()
	var has_route_fog: bool = route.y > route.x
	if has_route_fog:
		_place_sea_band(route)
	# Mais denso à medida que avança, até o máximo em NEAR.
	var growth: float = clampf(state.advance / state.config.near_advance, 0.0, 1.0)
	_fade(_sea_band, growth if has_route_fog else 0.0, delta)


func setup(fog: FogSystem, boat_path: Path3D) -> void:
	_fog = fog
	_boat_path = boat_path


func _place_sea_band(route: Vector2) -> void:
	var curve: Curve3D = _boat_path.curve
	var length: float = curve.get_baked_length()
	var start: Vector3 = _boat_path.to_global(curve.sample_baked(route.x * length))
	var end: Vector3 = _boat_path.to_global(curve.sample_baked(route.y * length))
	var along: Vector3 = end - start
	var x_axis: Vector3 = along.normalized()
	var half_length: float = maxf(along.length() * 0.5, sea_band_min_half_length)
	var band_basis := Basis(
		x_axis * half_length,
		Vector3.UP * sea_band_half_height,
		x_axis.cross(Vector3.UP) * sea_band_half_depth
	)
	_sea_band.global_transform = Transform3D(band_basis, (start + end) * 0.5)


func _fade(volume: MeshInstance3D, target: float, delta: float) -> void:
	var material := volume.material_override as ShaderMaterial
	var opacity: float = material.get_shader_parameter("opacity")
	_set_opacity(volume, move_toward(opacity, target, fade_per_second * delta))


func _set_opacity(volume: MeshInstance3D, opacity: float) -> void:
	var material := volume.material_override as ShaderMaterial
	material.set_shader_parameter("opacity", opacity)
	volume.visible = opacity > 0.0


func _all_volumes() -> Array[MeshInstance3D]:
	var volumes: Array[MeshInstance3D] = [_sea_band]
	volumes.append_array(_stage_volumes.keys())
	return volumes
