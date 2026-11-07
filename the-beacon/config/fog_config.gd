class_name FogConfig
extends Resource
## Nevoeiro (entrega 2): um avanço de 0 (sem nevoeiro) a 1 (cabine tomada), com estágios
## nos limiares abaixo (`FogStage`). Velocidades em avanço por segundo.

@export_group("Estágios")
## Começa a aparecer na câmera da porta e bloqueia o feixe.
@export_range(0.0, 1.0, 0.01) var near_advance: float = 0.3
@export_range(0.0, 1.0, 0.01) var ground_floor_advance: float = 0.45
@export_range(0.0, 1.0, 0.01) var stairs_advance: float = 0.6
@export_range(0.0, 1.0, 0.01) var trapdoor_advance: float = 0.75
@export_range(0.0, 1.0, 0.01) var cabin_advance: float = 0.9

@export_group("No mar")
## Avanço com que o nevoeiro surge.
@export_range(0.0, 1.0, 0.01) var start_advance: float = 0.05
## Teto do adensamento no mar com o farol operando; fica abaixo de `near_advance`.
@export_range(0.0, 1.0, 0.01) var sea_max_advance: float = 0.25
@export var sea_densify_per_second: float = 0.002
## Duração sorteada do nevoeiro no mar, contada só com o farol operando.
@export var min_duration_seconds: float = 90.0
@export var max_duration_seconds: float = 240.0
## Maior fração da rota dos barcos que o nevoeiro cobre; menor que 1 para nunca fechá-la.
@export_range(0.0, 0.95, 0.01) var max_route_coverage: float = 0.5

@export_group("Farol parado")
## Tempo do farol sem operar até o nevoeiro surgir sozinho.
@export var idle_grace_seconds: float = 45.0
@export var advance_per_second: float = 0.008

@export_group("Recuo")
## Depois de o farol voltar a operar com o nevoeiro perto, o avanço fica parado por este tempo
## antes de recuar. O feixe só volta quando o recuo leva o avanço abaixo de `near_advance`.
@export var unblock_seconds: float = 8.0
## Até onde ele recua; abaixo de `near_advance`.
@export_range(0.0, 1.0, 0.01) var recede_to_advance: float = 0.15
@export var recede_per_second: float = 0.03


## Lista os problemas desta config; vazia quando está pronta.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var thresholds: Array[float] = [
		start_advance,
		near_advance,
		ground_floor_advance,
		stairs_advance,
		trapdoor_advance,
		cabin_advance,
	]
	for index: int in range(1, thresholds.size()):
		if thresholds[index] <= thresholds[index - 1]:
			errors.append("fog: limiares dos estágios precisam crescer")
			break
	if sea_max_advance >= near_advance or recede_to_advance >= near_advance:
		errors.append("fog: teto no mar e recuo precisam ficar abaixo de near_advance")
	if min_duration_seconds > max_duration_seconds:
		errors.append("fog: duração mínima acima da máxima")
	return errors
