class_name TorsoAim
extends SkeletonModifier3D
## Ajusta o tronco do corpo do jogador depois da animação: desfaz o giro das pernas, para o tronco
## continuar de frente para onde o jogador olha, e inclina a coluna e o pescoço com o olhar para
## cima e para baixo. Os eixos são os do esqueleto (frente em +Z, como o modelo importado).

## Osso em que o giro das pernas é desfeito; tudo acima dele herda o ajuste.
@export var base_bone: StringName = &"spine_01"
## Ossos que acompanham a inclinação do olhar e a fração da inclinação que cada um recebe.
@export var pitch_bones: Dictionary[StringName, float] = {
	&"spine_02": 0.15,
	&"spine_03": 0.2,
	&"neck_01": 0.1,
}

## Giro das pernas, em radianos, que o tronco desfaz. Positivo para a direita.
var counter_yaw: float = 0.0
## Inclinação do olhar, em radianos. Positivo olhando para cima.
var look_pitch: float = 0.0


## Desfaz o giro das pernas no osso da base e inclina os ossos do olhar.
func _process_modification_with_delta(_delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	_rotate_in_skeleton_space(skeleton, base_bone, Basis(Vector3.UP, counter_yaw))
	for bone_name: StringName in pitch_bones:
		var angle: float = -look_pitch * pitch_bones[bone_name]
		_rotate_in_skeleton_space(skeleton, bone_name, Basis(Vector3.RIGHT, angle))


## Gira o osso por `rotation`, aplicada no referencial do esqueleto e em torno da origem do osso.
## Osso desconhecido é ignorado.
func _rotate_in_skeleton_space(
	skeleton: Skeleton3D, bone_name: StringName, rotation: Basis
) -> void:
	var index: int = skeleton.find_bone(bone_name)
	if index < 0:
		return
	var global_pose: Transform3D = skeleton.get_bone_global_pose(index)
	global_pose.basis = rotation * global_pose.basis
	var parent: int = skeleton.get_bone_parent(index)
	var local_pose: Transform3D = global_pose
	if parent >= 0:
		local_pose = skeleton.get_bone_global_pose(parent).affine_inverse() * global_pose
	skeleton.set_bone_pose_rotation(
		index, local_pose.basis.orthonormalized().get_rotation_quaternion()
	)
