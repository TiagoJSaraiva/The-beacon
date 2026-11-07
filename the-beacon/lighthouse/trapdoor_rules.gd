class_name TrapdoorRules
extends RefCounted
## Alçapão (entrega 2): aberto ou fechado, com trinco ligado ou desligado.
## - O trinco só existe com o alçapão fechado, e trancado o alçapão não abre.
## - O nevoeiro no alçapão desliga o trinco; ligar de novo só depois de ele sair e passar
##   `latch_relock_cooldown_seconds`.
## - O Afogado batendo com o trinco desligado abre o alçapão em `resistance_seconds`
##   (o tempo acumula até ele parar de bater); aí ele só fecha passado
##   `reclose_cooldown_seconds`.

var config: TrapdoorConfig
var is_open: bool = false
var is_latched: bool = false
var fog_present: bool = false

var _resistance_left: float
var _relock_left: float = 0.0
var _reclose_left: float = 0.0


## Cria o alçapão fechado, sem trinco, com a resistência cheia.
func _init(trapdoor_config: TrapdoorConfig) -> void:
	config = trapdoor_config
	_resistance_left = config.resistance_seconds


## Diz se o trinco pode ser ligado: alçapão fechado, sem nevoeiro e fora do intervalo depois do
## nevoeiro.
func can_latch() -> bool:
	return not is_open and not fog_present and _relock_left <= 0.0


## Diz se o jogador pode mexer no trinco: desligar é sempre possível; ligar depende de
## `can_latch`.
func can_toggle_latch() -> bool:
	return is_latched or can_latch()


## Desliga o trinco ligado ou, se `can_latch` permitir, liga o desligado.
func toggle_latch() -> void:
	if is_latched:
		is_latched = false
	elif can_latch():
		is_latched = true


## Diz se o jogador pode mexer no painel: fechar só fora do intervalo depois do arrombamento;
## abrir só sem o trinco.
func can_toggle_open() -> bool:
	if is_open:
		return _reclose_left <= 0.0
	return not is_latched


## Abre ou fecha pelo jogador, se permitido, e devolve se mudou.
func toggle_open() -> bool:
	if not can_toggle_open():
		return false
	is_open = not is_open
	return true


## Registra o nevoeiro no alçapão: ao chegar, desliga o trinco; ao sair, começa o intervalo para
## religá-lo.
func set_fog_present(present: bool) -> void:
	if present:
		is_latched = false
	elif fog_present:
		_relock_left = config.latch_relock_cooldown_seconds
	fog_present = present


## Avança os tempos. Devolve true no instante em que o Afogado abre o alçapão.
func tick(delta: float, banging: bool) -> bool:
	if not fog_present:
		_relock_left = maxf(0.0, _relock_left - delta)
	_reclose_left = maxf(0.0, _reclose_left - delta)
	if not banging:
		_resistance_left = config.resistance_seconds
		return false
	if is_open or is_latched:
		return false
	_resistance_left -= delta
	if _resistance_left > 0.0:
		return false
	is_open = true
	_reclose_left = config.reclose_cooldown_seconds
	_resistance_left = config.resistance_seconds
	return true
