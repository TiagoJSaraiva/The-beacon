class_name EntranceDoor
extends Node3D
## Porta do térreo (entrega 2). Não quebra nem tem conserto: o barulho do Afogado se
## aproximando vem de fora dela, e ao entrar ele a arromba (som e a folha abrindo e
## voltando). A colisão nunca abre: o jogador não sai do farol.

## Folha aberta para dentro (+X local) no arrombamento.
@export var burst_open_degrees: float = 80.0
@export var burst_open_seconds: float = 0.15
@export var burst_return_seconds: float = 1.2
## Volume do barulho de aproximação com o medidor quase vazio e cheio.
@export var approach_quiet_db: float = -30.0
@export var approach_loud_db: float = 3.0

var _swing: Tween

@onready var _leaf: Node3D = %Leaf
@onready var _burst_sound: AudioStreamPlayer3D = %BurstSound
@onready var _approach_noise: LoopingSound = %ApproachNoise


## Barulho do lado de fora, crescendo com a aproximação (0 a 1).
func show_approach(level: float) -> void:
	_approach_noise.set_active(level > 0.0)
	_approach_noise.volume_db = lerpf(approach_quiet_db, approach_loud_db, level)


func burst_open() -> void:
	_burst_sound.play()
	if _swing != null:
		_swing.kill()
	_swing = create_tween()
	_swing.tween_property(_leaf, "rotation:y", deg_to_rad(burst_open_degrees), burst_open_seconds)
	_swing.tween_property(_leaf, "rotation:y", 0.0, burst_return_seconds).set_trans(
		Tween.TRANS_SINE
	)
