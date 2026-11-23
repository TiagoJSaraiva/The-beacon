extends GdUnitTestSuite
## Ondas do mar: a crista mais alta fica bem abaixo do térreo do farol (y = 0). No shader do mar, a
## altura de cada onda é a `steepness` dela, e o deslocamento é a média das ondas.

const EXTERIOR := "res://exterior/exterior.tscn"
const GROUND_FLOOR_Y := 0.0
## Folga mínima entre a crista mais alta e o térreo.
const MIN_CLEARANCE := 1.5


func test_highest_crest_stays_below_the_ground_floor() -> void:
	var exterior: Node3D = auto_free((load(EXTERIOR) as PackedScene).instantiate())
	var sea: Node3D = exterior.get_node("Sea")
	var material: ShaderMaterial = sea.get("material")
	var count: int = material.get_shader_parameter(&"WaveCount")
	var steepnesses: PackedFloat32Array = material.get_shader_parameter(&"WaveSteepnesses")
	var total: float = 0.0
	for i in count:
		total += absf(steepnesses[i])
	var highest_crest: float = sea.position.y + total / count
	assert_float(highest_crest).is_less(GROUND_FLOOR_Y - MIN_CLEARANCE)
