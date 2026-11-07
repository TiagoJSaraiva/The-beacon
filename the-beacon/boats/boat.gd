class_name Boat
extends PathFollow3D
## Barco na rota do mar. Só visual: a regra está em BoatPassage, avançada pelo BoatDirector.

@export var sink_depth: float = 6.0
@export var sink_seconds: float = 4.0
## Para onde o barco segue depois de desviar, afastando-se da ilha.
@export var divert_offset: Vector3 = Vector3(0.0, 0.0, 60.0)
@export var divert_seconds: float = 10.0

var passage: BoatPassage

@onready var _hull: Node3D = %Hull


## Acompanha na rota o progresso da travessia, enquanto o barco está cruzando.
func _process(_delta: float) -> void:
	if passage != null and passage.outcome == BoatPassage.Outcome.CROSSING:
		progress_ratio = passage.progress


## Anima o casco afundando e apaga o barco ao final.
func sink() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_hull, "position:y", -sink_depth, sink_seconds)
	tween.parallel().tween_property(_hull, "rotation:z", deg_to_rad(25.0), sink_seconds)
	tween.tween_callback(queue_free)


## Anima o casco virando e se afastando da ilha e apaga o barco ao final.
func divert() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_hull, "rotation:y", _hull.rotation.y + PI * 0.5, divert_seconds * 0.3)
	tween.tween_property(
		_hull, "global_position", _hull.global_position + divert_offset, divert_seconds
	)
	tween.tween_callback(queue_free)
