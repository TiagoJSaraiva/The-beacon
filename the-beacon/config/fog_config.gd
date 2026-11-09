class_name FogConfig
extends Resource
## Nevoeiro (entrega 2): um avanço de 0 (acabou de surgir) a 1 (cobre o feixe), com estágios
## nos limiares abaixo (`FogStage`). Velocidades em avanço por segundo.

@export_group("Estágios")
## Começa a aparecer perto da entrada do farol (câmera da porta).
@export_range(0.0, 1.0, 0.01) var near_advance: float = 0.3
@export_range(0.0, 1.0, 0.01) var ground_floor_advance: float = 0.45
@export_range(0.0, 1.0, 0.01) var stairs_advance: float = 0.6
@export_range(0.0, 1.0, 0.01) var trapdoor_advance: float = 0.75
@export_range(0.0, 1.0, 0.01) var cabin_advance: float = 0.9
## Cobre a cabeça do farol e bloqueia o feixe; é o último estágio.
@export_range(0.0, 1.0, 0.01) var beam_cover_advance: float = 1.0

@export_group("No mar")
## Avanço com que o nevoeiro surge; ele nunca recua abaixo disso até o fim da noite.
@export_range(0.0, 1.0, 0.01) var start_advance: float = 0.05
## Centro do trecho coberto da rota dos barcos (fração da rota), no trecho em comum das
## câmeras do mar.
@export_range(0.0, 1.0, 0.01) var route_center: float = 0.5
## Maior fração da rota dos barcos que o nevoeiro cobre; menor que 1 para nunca fechá-la.
@export_range(0.0, 0.95, 0.01) var max_route_coverage: float = 0.5

@export_group("Farol parado")
## Tempo do farol sem operar até o nevoeiro surgir sozinho.
@export var idle_grace_seconds: float = 45.0
@export var advance_per_second: float = 0.008

@export_group("Recuo")
## Fração do avanço da última parada do farol que o nevoeiro devolve assim que o farol volta a
## operar.
@export_range(0.0, 1.0, 0.01) var recoil_ratio: float = 0.5
## Com o feixe coberto, o recuo imediato só acontece depois deste tempo com o farol operando.
@export var unblock_seconds: float = 8.0
## Recuo contínuo com o farol operando; menor que `advance_per_second`.
@export var recede_per_second: float = 0.002


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
		beam_cover_advance,
	]
	for index: int in range(1, thresholds.size()):
		if thresholds[index] <= thresholds[index - 1]:
			errors.append("fog: limiares dos estágios precisam crescer")
			break
	if recede_per_second >= advance_per_second:
		errors.append("fog: recuo contínuo precisa ser mais lento que o avanço")
	var half_coverage: float = max_route_coverage * 0.5
	if route_center - half_coverage < 0.0 or route_center + half_coverage > 1.0:
		errors.append("fog: trecho máximo da rota sai da rota")
	return errors
