class_name Boat
extends PathFollow3D
## Barco na rota do mar. Só visual: a regra está em BoatPassage, avançada pelo BoatDirector.

@export var sink_depth: float = 6.0
@export var sink_seconds: float = 4.0

var passage: BoatPassage

@onready var _hull: Node3D = %Hull


func _process(_delta: float) -> void:
	if passage != null and passage.outcome == BoatPassage.Outcome.PASSING:
		progress_ratio = passage.route_progress()


## Afunda devagar e some.
func sink() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_hull, "position:y", -sink_depth, sink_seconds)
	tween.parallel().tween_property(_hull, "rotation:z", deg_to_rad(25.0), sink_seconds)
	tween.tween_callback(queue_free)
