class_name IslandShape
extends RefCounted
## Regras puras do relevo da ilha do farol: a altura do chão a uma distância do centro e num ângulo.
## Perfil: platô plano em volta do farol, encosta até a praia no nível do mar e fundo raso. Um ruído
## pelo ângulo estica e encolhe os raios, para o contorno não ser um círculo.

var plateau_radius: float = 13.0
## Um pouco abaixo do piso do térreo (y = 0), para as duas superfícies não piscarem.
var plateau_height: float = -0.03
## Onde a encosta chega ao nível do mar (a praia).
var shore_radius: float = 27.0
var sea_level: float = -2.9
var seabed_radius: float = 36.0
var seabed_height: float = -5.5
## Fração dos raios que o ruído soma ou tira, conforme o ângulo.
var coast_variation: float = 0.15

var _noise: FastNoiseLite


## Cria o relevo com o ruído do contorno da semente dada.
func _init(noise_seed: int = 7) -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = noise_seed
	_noise.frequency = 1.2


## Devolve o fator (perto de 1) que estica ou encolhe os raios do relevo no ângulo dado (radianos).
func coast_scale(angle: float) -> float:
	# O ruído é lido num círculo, para o contorno fechar sem emenda em 0 e 2π.
	return 1.0 + coast_variation * _noise.get_noise_2d(cos(angle), sin(angle))


## Devolve a altura do chão a `distance` metros do centro, no ângulo dado (radianos).
func height_at(distance: float, angle: float) -> float:
	return profile(distance / coast_scale(angle))


## Devolve a altura do perfil sem ruído a `reach` metros do centro: platô, encosta suave nas pontas
## (íngreme no meio, plana perto da água), fundo descendo em linha reta e, depois, plano.
func profile(reach: float) -> float:
	if reach <= plateau_radius:
		return plateau_height
	if reach <= shore_radius:
		var slope: float = (reach - plateau_radius) / (shore_radius - plateau_radius)
		return lerpf(plateau_height, sea_level, smoothstep(0.0, 1.0, slope))
	var seabed: float = clampf((reach - shore_radius) / (seabed_radius - shore_radius), 0.0, 1.0)
	return lerpf(sea_level, seabed_height, seabed)
