class_name LighthouseTab
extends DebugTab
## Aba "Farol" do painel de debug: falhas e consertos, energia, galão, alavanca e trinco, sem ir
## até cada objeto.

const PERCENT := 100.0

var _lighthouse: Lighthouse


## Monta a aba para o farol dado.
func setup(lighthouse: Lighthouse) -> void:
	_lighthouse = lighthouse
	add_title("Falhas")
	add_buttons(
		{
			"Queimar lâmpada": _burn_lamp,
			"Trocar lâmpada": _lighthouse.lamp.replace,
			"Quebrar casa de máquinas": _break_machine,
			"Consertar casa de máquinas": _lighthouse.machine_house.repair,
			"Estourar mangueira": _lighthouse.burst_hose,
		}
	)
	add_title("Energia e galão")
	add_value_action(
		"Gerador de emergência (%)",
		0.0,
		PERCENT,
		1.0,
		lighthouse.emergency_generator.state.fuel_ratio() * PERCENT,
		"Definir",
		_set_emergency_fuel
	)
	add_buttons(
		{"Encher galão": _fill_jerrycan.bind(true), "Esvaziar galão": _fill_jerrycan.bind(false)}
	)
	add_title("Controles")
	add_buttons({"Alavanca do feixe": _lighthouse.beam_control.toggle, "Trinco": _toggle_latch})
	add_status()


## Devolve o estado do feixe, da energia e das peças, em duas linhas.
func readout() -> String:
	if _lighthouse == null:
		return ""
	var beam: BeamState = _lighthouse.beam
	var beam_line: String = (
		"Feixe: alavanca %s, %s, %s · lâmpada %s · casa %s"
		% [
			_on_off(beam.switch_on),
			"operando" if beam.is_operational() else "parado",
			"aceso" if beam.is_lit() else "apagado",
			"queimada" if beam.lamp_burned else "ok",
			"quebrada" if beam.machine_broken else "ok",
		]
	)
	var power_line: String = (
		"Energia: principal %s, emergência %d%% · galão %d%%"
		% [
			"ok" if _lighthouse.main_generator.is_running() else "parado",
			roundi(_lighthouse.emergency_generator.state.fuel_ratio() * PERCENT),
			roundi(_lighthouse.jerrycan.state.ratio() * PERCENT),
		]
	)
	return beam_line + "\n" + power_line


## Queima a lâmpada mesmo no intervalo depois da última troca.
func _burn_lamp() -> void:
	_lighthouse.lamp.failure.skip_cooldown()
	_lighthouse.lamp.burn_out()


## Quebra a casa de máquinas mesmo no intervalo depois do último conserto.
func _break_machine() -> void:
	_lighthouse.machine_house.failure.skip_cooldown()
	_lighthouse.machine_house.break_down()


## Define o combustível do gerador de emergência em porcentagem; o gerador atualiza medidor e
## energia no próximo frame.
func _set_emergency_fuel(percent: float) -> void:
	_lighthouse.emergency_generator.state.set_fuel_ratio(percent / PERCENT)
	show_status("Gerador de emergência em %d%%." % roundi(percent))


## Enche ou esvazia o galão, onde quer que ele esteja.
func _fill_jerrycan(full: bool) -> void:
	var jerrycan: JerrycanState = _lighthouse.jerrycan.state
	jerrycan.amount = jerrycan.capacity if full else 0.0


## Inverte o trinco se as regras permitirem e diz o resultado.
func _toggle_latch() -> void:
	var trapdoor: Trapdoor = _lighthouse.trapdoor
	var was_latched: bool = trapdoor.is_latched()
	trapdoor.toggle_latch()
	if trapdoor.is_latched() == was_latched:
		show_status("O trinco não mudou (nevoeiro no alçapão, alçapão aberto ou intervalo).")
	else:
		show_status("Trinco %s." % _on_off(trapdoor.is_latched()))


## Devolve "ligado" ou "desligado".
func _on_off(on: bool) -> String:
	return "ligado" if on else "desligado"
