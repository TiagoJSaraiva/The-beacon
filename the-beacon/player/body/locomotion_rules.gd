class_name LocomotionRules
extends RefCounted
## Regras puras da animação de locomoção do corpo do jogador: a partir da velocidade, escolhe o
## passo (parado, andar ou trote), para onde as pernas apontam e a que velocidade a animação toca.
## O pacote de animações só tem movimento para a frente. Andar de lado ou de costas gira as
## pernas na direção do movimento (até 90°) e, de costas, toca a animação ao contrário.

enum Gait { IDLE, WALK, JOG }

## Abaixo desta velocidade horizontal (m/s) o corpo está parado.
const IDLE_BELOW := 0.1
## Até esta velocidade (m/s) o passo é o andar; acima, o trote.
const WALK_MAX_SPEED := 2.0
## Velocidade em que cada animação anda sozinha (m/s), medida no pacote com root motion. Tocar a
## animação a `velocidade / nominal` mantém os pés no chão.
const WALK_NOMINAL_SPEED := 0.97
const JOG_NOMINAL_SPEED := 5.36
## Limites da velocidade de reprodução, para o analógico inclinado não deixar a animação lenta
## ou acelerada demais.
const MIN_TIME_SCALE := 0.5
const MAX_TIME_SCALE := 2.2
## Fração da velocidade que precisa apontar para o lado oposto antes de a animação inverter
## (0 = exatamente de lado).
const REVERSE_HYSTERESIS := 0.2


## Devolve a velocidade horizontal no referencial do corpo: x para a direita, y para a frente.
## `facing` é a base global do corpo (a frente é -Z).
static func local_velocity(velocity: Vector3, facing: Basis) -> Vector2:
	var local: Vector3 = facing.inverse() * velocity
	return Vector2(local.x, -local.z)


## Devolve o passo para a velocidade horizontal `speed` (m/s).
static func gait(speed: float) -> Gait:
	if speed < IDLE_BELOW:
		return Gait.IDLE
	if speed <= WALK_MAX_SPEED:
		return Gait.WALK
	return Gait.JOG


## Diz se a animação deve tocar ao contrário: o movimento local aponta para trás. Com histerese
## (`REVERSE_HYSTERESIS`), para o corpo não alternar a cada quadro ao andar de lado, e parado
## mantém o estado anterior (`was_reversed`).
static func is_reversed(local: Vector2, was_reversed: bool) -> bool:
	var length: float = local.length()
	if length < IDLE_BELOW:
		return was_reversed
	var forward_share: float = local.y / length
	if was_reversed:
		return forward_share < REVERSE_HYSTERESIS
	return forward_share < -REVERSE_HYSTERESIS


## Devolve, em radianos, o giro das pernas em relação à frente do corpo: 0 para a frente, positivo
## para a direita, dentro de ±90°. Com `reversed`, as pernas apontam para o lado oposto ao do
## movimento (a animação toca ao contrário). Parado, devolve 0.
static func leg_yaw(local: Vector2, reversed: bool) -> float:
	if local.length() < IDLE_BELOW:
		return 0.0
	var direction: Vector2 = -local if reversed else local
	return clampf(atan2(direction.x, direction.y), -PI / 2.0, PI / 2.0)


## Devolve a velocidade de reprodução da animação do passo: `speed / nominal` dentro dos limites,
## negativa se `reversed`. Parado, toca em velocidade normal.
static func time_scale(gait_kind: Gait, speed: float, reversed: bool) -> float:
	var nominal: float = 1.0
	match gait_kind:
		Gait.WALK:
			nominal = WALK_NOMINAL_SPEED
		Gait.JOG:
			nominal = JOG_NOMINAL_SPEED
		Gait.IDLE:
			return 1.0
	var scale: float = clampf(speed / nominal, MIN_TIME_SCALE, MAX_TIME_SCALE)
	return -scale if reversed else scale
