class_name SlipperyRoof
extends CollisionShape3D
## Telhado de duas águas invisível sobre o topo de uma caixa (`RidgeRoof`), para o jogador e o
## galão escorregarem em vez de pararem em cima da máquina. O nó fica no centro do topo. Fica num
## corpo da camada `slippery_tops`, que o jogador e os props enxergam e os raios e a navmesh
## ignoram: o telhado não bloqueia a mira nas peças do topo da máquina.

## Largura (X) e profundidade (Z) do topo da caixa.
@export var box_top_size: Vector2 = Vector2.ONE
## Inclinação das águas. Precisa passar da maior rampa em que o jogador para de pé (45°).
@export_range(46.0, 85.0, 1.0) var angle_degrees: float = 60.0


## Monta a forma do telhado a partir das medidas do topo.
func _ready() -> void:
	var roof := ConvexPolygonShape3D.new()
	roof.points = RidgeRoof.over_box_top(box_top_size.x, box_top_size.y, angle_degrees)
	shape = roof
