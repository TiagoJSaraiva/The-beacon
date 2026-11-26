class_name PlayerBody
extends Node3D
## Corpo humano do jogador: toca as animações do manequim conforme o movimento e o estado, com as
## pernas viradas para onde ele anda (`LocomotionRules`) e o tronco de frente para o olhar
## (`TorsoAim`). Quem chama informa o estado a cada quadro em `update_body`.

## Estado do corpo: em pé (andando ou parado), sentado, ajoelhado ou agarrado na escada de mão.
enum Pose { STANDING, SEATED, KNEELING, CLIMBING }

## Camadas de render (`project.godot`, `layer_names`): a cópia do corpo sem a cabeça só aparece
## para a câmera do jogador, e a cópia inteira para as outras câmeras e para as sombras. Cada câmera
## deixa de fora a camada que não deve ver.
const PLAYER_VIEW_LAYER := 1 << 2
const WORLD_VIEW_LAYER := 1 << 3
## Osso da cabeça: os triângulos que ele move mais da metade somem da cópia vista pelo jogador.
const HEAD_BONE := &"Head"
const HEAD_WEIGHT_LIMIT := 0.5

## Estados da transição principal e a animação de cada um (nomes do pacote, sem o `_Loop`).
const STATE_ANIMATIONS: Dictionary[StringName, StringName] = {
	&"idle": &"Idle",
	&"walk": &"Walk",
	&"jog": &"Jog_Fwd",
	&"jump": &"Jump",
	&"sit": &"Sitting_Idle",
	&"kneel": &"Crouch_Idle",
}
const GAIT_STATES: Dictionary[LocomotionRules.Gait, StringName] = {
	LocomotionRules.Gait.IDLE: &"idle",
	LocomotionRules.Gait.WALK: &"walk",
	LocomotionRules.Gait.JOG: &"jog",
}

## Rapidez com que as pernas giram para a direção do movimento (peso por segundo).
@export var leg_turn_speed: float = 10.0
## Tempo da mistura entre duas animações.
@export var crossfade_seconds: float = 0.2
## Tempo sem pisar no chão até o corpo passar para a animação de pulo; evita piscar nos degraus.
@export var airborne_delay_seconds: float = 0.15

var _reversed: bool = false
var _leg_yaw: float = 0.0
var _off_floor_seconds: float = 0.0
var _state: StringName = &""
var _torso: TorsoAim
var _skeleton: Skeleton3D

@onready var _visual: Node3D = $Visual
@onready var _tree: AnimationTree = $AnimationTree


## Acha o esqueleto e o `AnimationPlayer` do modelo, separa a cópia do corpo sem cabeça para a
## câmera do jogador, põe o ajuste do tronco no esqueleto e monta a árvore de animação.
func _ready() -> void:
	var rig: Node = $Visual/Rig
	var animation_player := (
		rig.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	)
	_skeleton = rig.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	_split_views()
	_torso = TorsoAim.new()
	_skeleton.add_child(_torso)
	_build_tree(animation_player)


## Atualiza o corpo: escolhe a animação do `pose` e do movimento, vira as pernas para onde o
## jogador anda e inclina o tronco com o olhar. `velocity` é a do jogador, `facing` a base global
## dele (a frente é -Z), `look_pitch` a inclinação do olhar em radianos (positivo para cima) e
## `on_floor` diz se os pés estão no chão.
func update_body(
	pose: Pose, velocity: Vector3, facing: Basis, look_pitch: float, on_floor: bool, delta: float
) -> void:
	var local := Vector2.ZERO
	if pose == Pose.STANDING:
		local = LocomotionRules.local_velocity(Vector3(velocity.x, 0.0, velocity.z), facing)
	var speed: float = local.length()
	_reversed = LocomotionRules.is_reversed(local, _reversed)
	var gait: LocomotionRules.Gait = LocomotionRules.gait(speed)
	_off_floor_seconds = 0.0 if on_floor else _off_floor_seconds + delta
	var airborne: bool = pose == Pose.STANDING and _off_floor_seconds > airborne_delay_seconds
	_request_state(_state_for(pose, gait, airborne))
	var walking: bool = pose == Pose.STANDING and not airborne
	var time_scale: float = LocomotionRules.time_scale(gait, speed, _reversed) if walking else 1.0
	_tree.set("parameters/speed/scale", time_scale)
	var target_yaw: float = LocomotionRules.leg_yaw(local, _reversed) if walking else 0.0
	_leg_yaw = lerp_angle(_leg_yaw, target_yaw, clampf(leg_turn_speed * delta, 0.0, 1.0))
	# O modelo olha para +Z e o jogador para -Z: meia volta mais o giro das pernas (a direita é
	# um giro negativo em Y).
	_visual.rotation.y = PI - _leg_yaw
	_torso.counter_yaw = _leg_yaw
	_torso.look_pitch = look_pitch


## Devolve o estado da transição principal (`idle`, `walk`, `jog`, `jump`, `sit` ou `kneel`).
func current_state() -> StringName:
	return _state


## Devolve o giro atual das pernas em relação à frente do corpo, em radianos.
func leg_yaw() -> float:
	return _leg_yaw


## Deixa a malha do modelo como a cópia inteira (camada do mundo, que projeta sombra) e cria ao
## lado dela a cópia sem cabeça (camada do jogador, sem sombra).
func _split_views() -> void:
	var full := _skeleton.find_children("*", "MeshInstance3D", false, false)[0] as MeshInstance3D
	full.layers = WORLD_VIEW_LAYER
	var view := full.duplicate() as MeshInstance3D
	view.name = "PlayerViewMesh"
	view.layers = PLAYER_VIEW_LAYER
	view.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	view.mesh = _mesh_without_head(full.mesh, full.skin)
	_skeleton.add_child(view)


## Devolve uma cópia da malha sem os triângulos que têm algum vértice movido pelo osso da cabeça
## em mais de `HEAD_WEIGHT_LIMIT`. Pelo peso de pele, o corte acompanha a cabeça em qualquer pose.
## A malha deve ter a pele `skin`, que diz a qual osso cada índice de osso se refere.
func _mesh_without_head(source: Mesh, skin: Skin) -> ArrayMesh:
	var head_bone: int = _skeleton.find_bone(HEAD_BONE)
	var head_binds: Dictionary[int, bool] = {}
	for bind: int in skin.get_bind_count():
		if skin.get_bind_name(bind) == HEAD_BONE or skin.get_bind_bone(bind) == head_bone:
			head_binds[bind] = true
	var result := ArrayMesh.new()
	for surface: int in source.get_surface_count():
		var arrays: Array = source.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var influences: int = bones.size() / vertices.size()
		var is_head := PackedByteArray()
		is_head.resize(vertices.size())
		for vertex: int in vertices.size():
			var head_weight: float = 0.0
			for slot: int in influences:
				if head_binds.has(bones[vertex * influences + slot]):
					head_weight += weights[vertex * influences + slot]
			is_head[vertex] = 1 if head_weight > HEAD_WEIGHT_LIMIT else 0
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var kept := PackedInt32Array()
		for corner: int in range(0, indices.size(), 3):
			if (
				(
					is_head[indices[corner]]
					+ is_head[indices[corner + 1]]
					+ is_head[indices[corner + 2]]
				)
				== 0
			):
				kept.append_array(indices.slice(corner, corner + 3))
		arrays[Mesh.ARRAY_INDEX] = kept
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		result.surface_set_material(surface, source.surface_get_material(surface))
	return result


## Devolve o estado de animação para a pose e o passo.
func _state_for(pose: Pose, gait: LocomotionRules.Gait, airborne: bool) -> StringName:
	match pose:
		Pose.SEATED:
			return &"sit"
		Pose.KNEELING:
			return &"kneel"
		Pose.CLIMBING:
			return &"idle"
	if airborne:
		return &"jump"
	return GAIT_STATES[gait]


## Pede a transição para o estado, só quando ele muda.
func _request_state(state: StringName) -> void:
	if state == _state:
		return
	_state = state
	_tree.set("parameters/gait/transition_request", state)


## Monta a árvore: uma transição entre os estados seguida da velocidade de reprodução.
func _build_tree(animation_player: AnimationPlayer) -> void:
	var blend_tree := AnimationNodeBlendTree.new()
	var gait := AnimationNodeTransition.new()
	gait.input_count = STATE_ANIMATIONS.size()
	gait.xfade_time = crossfade_seconds
	blend_tree.add_node(&"gait", gait)
	var index: int = 0
	for state: StringName in STATE_ANIMATIONS:
		gait.set_input_name(index, state)
		var clip := AnimationNodeAnimation.new()
		clip.animation = STATE_ANIMATIONS[state]
		var clip_name := StringName("clip_%s" % state)
		blend_tree.add_node(clip_name, clip)
		blend_tree.connect_node(&"gait", index, clip_name)
		index += 1
	blend_tree.add_node(&"speed", AnimationNodeTimeScale.new())
	blend_tree.connect_node(&"speed", 0, &"gait")
	blend_tree.connect_node(&"output", 0, &"speed")
	_tree.tree_root = blend_tree
	_tree.root_node = _tree.get_path_to(animation_player.get_node(animation_player.root_node))
	_tree.anim_player = _tree.get_path_to(animation_player)
	_tree.active = true
