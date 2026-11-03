class_name Figurehead
extends Node3D
## Carranca: imóvel e translúcida. Quando o diretor manda, pula no jogador ou se dissolve.
## Não tem corpo físico: não bloqueia nada.

## O pulo chegou ao jogador.
signal landed

@export var chest_height: float = 1.2
@export var jump_seconds: float = 0.25
@export var dissolve_seconds: float = 0.35

## Área do farol onde surgiu (`FigureheadSpawnRules.Area`).
var area: FigureheadSpawnRules.Area = FigureheadSpawnRules.Area.GROUND_FLOOR
## Tempo contínuo sob a lanterna.
var lit_seconds: float = 0.0
## Pulando ou se dissolvendo: já não reage a nada.
var is_finishing: bool = false


## Ponto que a lanterna precisa iluminar.
func chest_position() -> Vector3:
	return global_position + Vector3.UP * chest_height


## Vira de frente para um ponto, só no plano horizontal.
func face(point: Vector3) -> void:
	var flat := Vector3(point.x, global_position.y, point.z)
	if flat.distance_to(global_position) > 0.01:
		look_at(flat, Vector3.UP)


func jump_at(target: Vector3) -> void:
	is_finishing = true
	face(target)
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target, jump_seconds)
	tween.tween_callback(landed.emit)


## Some esmaecendo e se libera.
func dissolve() -> void:
	is_finishing = true
	var tween: Tween = create_tween().set_parallel()
	for part: Node in find_children("*", "GeometryInstance3D"):
		tween.tween_property(part, "transparency", 1.0, dissolve_seconds)
	tween.chain().tween_callback(queue_free)
