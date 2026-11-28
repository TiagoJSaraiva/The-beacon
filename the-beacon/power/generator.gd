class_name Generator
extends Node3D
## Gerador (decisão 0017). Cada papel tem a sua cena: o principal (`main_generator.tscn`) é
## alimentado pela mangueira do tanque, e o de emergência (`emergency_generator.tscn`) é
## abastecido com o galão pela boca de combustível. Alimenta só a casa de máquinas e a lâmpada;
## quem decide a fonte ativa é o farol.

signal power_changed(powered: bool)
## Jogador segurou E na boca de combustível com o galão; o farol faz a transferência.
signal refuel_requested
## O nível de combustível (0 a 1) mudou; repetido pelos medidores longe do gerador.
signal fuel_ratio_changed(ratio: float)

@export var feed: GeneratorState.Feed = GeneratorState.Feed.FUEL
## Boca de combustível com medidor. Só o gerador abastecido com o galão tem uma.
@export var fuel_inlet: FuelInlet

var state: GeneratorState

var _was_running: bool = false
var _last_fuel_ratio: float = -1.0

@onready var _hum: LoopingSound = %Hum


## Cria o estado com valores padrão e avisa se o papel por combustível ficou sem boca.
func _ready() -> void:
	if feed == GeneratorState.Feed.FUEL and fuel_inlet == null:
		push_warning("%s: gerador por combustível sem FuelInlet; o galão não o abastece." % name)
	# Valores padrão até o configure(): o farol consulta o estado logo ao montar.
	state = GeneratorState.new(PowerConfig.new(), feed)
	_was_running = state.is_running()
	_refresh()


## Gasta combustível, se estiver em uso, e atualiza medidor, som e sinal.
func _process(delta: float) -> void:
	state.tick(delta)
	_refresh()


## Recria o estado com os valores da dificuldade, mantendo a condição da mangueira.
func configure(power: PowerConfig) -> void:
	var hose_intact: bool = state.hose_intact
	state = GeneratorState.new(power, feed)
	state.hose_intact = hose_intact
	if fuel_inlet != null:
		fuel_inlet.set_pour_seconds(power.jerrycan_pour_seconds)
	_refresh()


## Diz se o gerador fornece energia agora.
func is_running() -> bool:
	return state.is_running()


## Informa se a mangueira está inteira. Só afeta o gerador alimentado por ela.
func set_hose_intact(intact: bool) -> void:
	state.hose_intact = intact
	_refresh()


## Informa se o gerador é a fonte ativa do farol ligado, condição para gastar e zumbir no papel
## por combustível.
func set_in_use(in_use: bool) -> void:
	state.in_use = in_use
	_refresh()


## Atualiza medidor e zumbido, emite `power_changed` só quando a energia muda e
## `fuel_ratio_changed` só quando o nível muda.
func _refresh() -> void:
	var ratio: float = state.fuel_ratio()
	if fuel_inlet != null:
		fuel_inlet.show_fuel_ratio(ratio)
	if not is_equal_approx(ratio, _last_fuel_ratio):
		_last_fuel_ratio = ratio
		fuel_ratio_changed.emit(ratio)
	var running: bool = state.is_running()
	# O de emergência só faz barulho quando está de fato alimentando o farol.
	_hum.set_active(running and (feed == GeneratorState.Feed.HOSE or state.in_use))
	if running != _was_running:
		_was_running = running
		power_changed.emit(running)


## Pede para despejar o galão quando a boca de combustível avisa o despejo.
func _on_fuel_inlet_pour_completed() -> void:
	refuel_requested.emit()
