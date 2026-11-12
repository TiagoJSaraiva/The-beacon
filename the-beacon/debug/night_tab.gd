class_name NightTab
extends DebugTab
## Aba "Noite" do painel de debug: hora, velocidade do relógio, fim e recomeço da noite, disparo
## manual de eventos e o liga-desliga do sorteio.

## O testador pediu para recomeçar a noite (mesmo `RunState`, valores editados).
signal restart_night_requested

const HOUR_STEP := 0.25
const LAST_HOUR := 23.75
const MAX_TIME_SCALE := 600.0

var _night: NightDirector
var _events: EventDirector


## Monta a aba para o relógio e o sorteio da noite.
func setup(night: NightDirector, events: EventDirector) -> void:
	_night = night
	_events = events
	add_title("Relógio")
	add_value_action(
		"Ir para a hora", 0.0, LAST_HOUR, HOUR_STEP, night.clock.clock_hour(), "Ir", _go_to_hour
	)
	add_value_action(
		"Velocidade (x)",
		0.0,
		MAX_TIME_SCALE,
		1.0,
		night.debug_time_scale,
		"Aplicar",
		func(value: float) -> void: _night.debug_time_scale = value
	)
	add_buttons(
		{
			"Terminar a noite": _end_night,
			"Recomeçar a noite": restart_night_requested.emit,
		}
	)
	add_title("Eventos")
	add_toggle(
		"Sorteio de eventos ligado",
		events.random_events_enabled,
		func(pressed: bool) -> void: _events.random_events_enabled = pressed
	)
	var buttons: Dictionary[String, Callable] = {}
	for event_id: StringName in events.registered_events():
		buttons["Disparar %s" % event_id] = _trigger.bind(event_id)
	add_buttons(buttons)
	add_status()


## Devolve a noite, a hora e a velocidade do relógio.
func readout() -> String:
	if _night == null:
		return ""
	return (
		"Noite %d · %s · relógio x%s"
		% [_night.current_night, _night.clock.display_text(), _night.debug_time_scale]
	)


## Leva o relógio à hora dada; o `NightDirector` publica o horário no próximo frame.
func _go_to_hour(hour: float) -> void:
	_night.clock.set_clock_hour(hour)
	show_status("Relógio em %s." % _night.clock.display_text())


## Leva o relógio ao fim da noite; ela termina no próximo frame com o `World` rodando.
func _end_night() -> void:
	_night.clock.set_clock_hour(_night.clock.config.night_end_hour)
	show_status("Fim da noite no próximo frame.")


## Dispara o evento e diz se o sistema aceitou.
func _trigger(event_id: StringName) -> void:
	if _events.trigger_now(event_id):
		show_status("Evento %s disparado." % event_id)
	else:
		show_status("O sistema recusou %s agora (já ativo ou no limite)." % event_id)
