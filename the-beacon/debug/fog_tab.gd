class_name FogTab
extends DebugTab
## Aba "Nevoeiro" do painel de debug: fazer surgir, fixar o avanço ou o estágio, congelar e
## limpar o nevoeiro da noite, e mover a faixa no mar para testar posições.

const ADVANCE_STEP := 0.01
## Limite e passo do deslocamento da faixa no mar, em metros.
const OFFSET_LIMIT := 200.0
const OFFSET_STEP := 1.0

var _fog: FogSystem
var _visuals: FogVisuals


## Monta a aba para o nevoeiro e o visual dele.
func setup(fog: FogSystem, visuals: FogVisuals) -> void:
	_fog = fog
	_visuals = visuals
	add_buttons({"Surgir agora": _start, "Limpar (antes de surgir)": _clear})
	add_toggle("Congelar avanço", fog.frozen, func(pressed: bool) -> void: _fog.frozen = pressed)
	add_value_action(
		"Avanço (0–1)", 0.0, 1.0, ADVANCE_STEP, fog.state.advance, "Fixar", _set_advance
	)
	add_title("Ir para o estágio")
	var buttons: Dictionary[String, Callable] = {}
	for stage_name: String in FogStage.Stage.keys():
		var stage: FogStage.Stage = FogStage.Stage[stage_name]
		if stage != FogStage.Stage.NONE:
			buttons[stage_name] = _go_to_stage.bind(stage)
	add_buttons(buttons)
	add_title("Faixa no mar (só o visual; os barcos afundam no trecho da rota)")
	var axes: Dictionary[String, int] = {
		"Ao longo da rota (m)": Vector3.AXIS_X,
		"Altura (m)": Vector3.AXIS_Y,
		"Para o lado, + afasta do farol (m)": Vector3.AXIS_Z,
	}
	for label: String in axes:
		var axis: int = axes[label]
		add_value_action(
			label,
			-OFFSET_LIMIT,
			OFFSET_LIMIT,
			OFFSET_STEP,
			visuals.sea_band_offset[axis],
			"Aplicar",
			_set_sea_band_offset.bind(axis)
		)
	add_status()


## Devolve a fase, o avanço, o estágio e o trecho da rota coberto.
func readout() -> String:
	if _fog == null:
		return ""
	var state: FogState = _fog.state
	var route: Vector2 = state.route_segment()
	return (
		"Nevoeiro: %s · avanço %.3f · %s · rota %.2f–%.2f%s"
		% [
			FogState.Phase.keys()[state.phase],
			state.advance,
			FogStage.Stage.keys()[state.stage()],
			route.x,
			route.y,
			" · congelado" if _fog.frozen else "",
		]
	)


## Faz o nevoeiro surgir no mar, se ainda não surgiu.
func _start() -> void:
	if not _fog.can_start():
		show_status("O nevoeiro já surgiu nesta noite.")
		return
	_fog.start()
	show_status("Nevoeiro surgiu no mar.")


## Volta o nevoeiro ao começo da noite. O que ele já causou (mangueira estourada) continua.
func _clear() -> void:
	_fog.state.clear()
	show_status("Nevoeiro limpo; a mangueira, se estourou, segue estourada.")


## Fixa o avanço; o sistema publica o estágio novo no próximo frame.
func _set_advance(value: float) -> void:
	_fog.state.force_advance(value)
	show_status("Avanço fixado em %.2f." % value)


## Desloca a faixa no mar num eixo e mostra o valor para copiar no `FogVisuals` da cena.
func _set_sea_band_offset(value: float, axis: int) -> void:
	_visuals.sea_band_offset[axis] = value
	var text: String = "sea_band_offset = %s" % _visuals.sea_band_offset
	print("[debug] FogVisuals.%s" % text)
	show_status("Faixa no mar: %s (também no console)." % text)


## Leva o avanço ao começo do estágio.
func _go_to_stage(stage: FogStage.Stage) -> void:
	_set_advance(FogStage.threshold(stage, _fog.state.config))
