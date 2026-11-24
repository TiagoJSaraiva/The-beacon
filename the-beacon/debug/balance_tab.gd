class_name BalanceTab
extends DebugTab
## Aba "Tabela" do painel de debug: a tabela de balanceamento por noite de uma dificuldade
## (decisão 0031). A célula da noite em jogo vale na hora; as outras valem quando aquela noite for
## jogada. As edições ficam no `BalanceService` até fechar o jogo, e "Salvar" as grava no arquivo.

## Campos que os sistemas copiam ao montar a noite: só valem ao recomeçá-la.
const RESTART_ONLY: Dictionary[String, Array] = {
	"power": [&"jerrycan_capacity", &"jerrycan_slot_fill_seconds", &"jerrycan_pour_seconds"],
	"repair":
	[
		&"lamp_replace_seconds",
		&"lamp_burnout_cooldown_seconds",
		&"machine_repair_seconds",
		&"machine_breakdown_cooldown_seconds",
	],
	"trapdoor": [&"latch_toggle_seconds"],
	"flashlight": [&"battery_seconds", &"beam_range", &"beam_half_angle_degrees"],
}
const LEGEND := (
	"▶ = noite em jogo · laranja = muda em relação à noite anterior · * = vale ao recomeçar a"
	+ " noite (aba Noite)"
)

var _catalog: DifficultyCatalog
## Dificuldade em jogo, os valores vivos da noite e o número dela.
var _playing: DifficultyConfig
var _live_config: DifficultyConfig
var _playing_night: int = 0
## Dificuldade mostrada na grade.
var _shown: DifficultyConfig
var _picker: OptionButton
var _grid: NightTableGrid


## Monta a barra da aba e a grade da dificuldade em jogo. `live_config` é a cópia que os sistemas
## da noite usam: a célula da noite em jogo é aplicada nela.
func setup(
	catalog: DifficultyCatalog,
	playing: DifficultyConfig,
	live_config: DifficultyConfig,
	playing_night: int
) -> void:
	_catalog = catalog
	_playing = playing
	_live_config = live_config
	_playing_night = playing_night
	_add_picker()
	add_buttons(
		{
			"Salvar": save_table,
			"Descartar alterações": discard_changes,
			"Copiar para as noites seguintes": fill_following,
		}
	)
	add_status(LEGEND)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_grid = NightTableGrid.new()
	_grid.cell_changed.connect(_on_grid_cell_changed)
	scroll.add_child(_grid)
	add_child(scroll)
	show_difficulty(playing)


## Diz quais dificuldades têm alterações não salvas na tabela.
func readout() -> String:
	var names := PackedStringArray()
	for difficulty: DifficultyConfig in _difficulties():
		if BalanceService.has_unsaved_changes(difficulty.id):
			names.append(difficulty.display_name)
	if names.is_empty():
		return ""
	return "Tabela com alterações não salvas: %s" % ", ".join(names)


## Mostra na grade a tabela da dificuldade; a coluna da noite em jogo só aparece destacada na
## dificuldade em jogo.
func show_difficulty(difficulty: DifficultyConfig) -> void:
	_shown = difficulty
	var current_night: int = _playing_night if _is_playing(difficulty) else 0
	_grid.build(BalanceService.table_for(difficulty), current_night, _restart_keys())


## Grava a tabela mostrada e diz onde.
func save_table() -> void:
	var error: Error = BalanceService.save(_shown.id)
	if error == OK:
		show_status("Tabela %s salva em %s." % [_shown.display_name, _save_location()])
	else:
		show_status("Não deu para salvar em %s (%s)." % [_save_location(), error_string(error)])


## Volta a tabela mostrada ao que está no arquivo e reaplica a noite em jogo.
func discard_changes() -> void:
	BalanceService.discard(_shown.id)
	show_difficulty(_shown)
	_apply_live()
	show_status("Alterações da tabela %s descartadas." % _shown.display_name)


## Copia a última célula usada para as noites seguintes da mesma linha.
func fill_following() -> void:
	if _grid.last_key.is_empty():
		show_status("Clique numa célula antes de copiar.")
		return
	BalanceService.table_for(_shown).fill_following(_grid.last_key, _grid.last_night)
	BalanceService.mark_changed(_shown.id)
	_grid.refresh()
	_apply_live()
	show_status("%s copiado da noite %d em diante." % [_grid.last_key, _grid.last_night])


## Acrescenta a escolha da dificuldade mostrada, na ordem do catálogo.
func _add_picker() -> void:
	_picker = OptionButton.new()
	for difficulty: DifficultyConfig in _difficulties():
		_picker.add_item(difficulty.display_name)
	var difficulties: Array[DifficultyConfig] = _difficulties()
	for index: int in difficulties.size():
		if _is_playing(difficulties[index]):
			_picker.select(index)
	_picker.item_selected.connect(func(index: int) -> void: show_difficulty(_difficulties()[index]))
	add_child(_picker)


## Devolve as dificuldades do catálogo; sem catálogo, só a que está em jogo.
func _difficulties() -> Array[DifficultyConfig]:
	if _catalog == null:
		return [_playing]
	return _catalog.difficulties


## Diz se a dificuldade é a que está em jogo.
func _is_playing(difficulty: DifficultyConfig) -> bool:
	return _playing != null and difficulty.id == _playing.id


## Aplica nos valores vivos a coluna da noite em jogo, se a grade mostra a dificuldade em jogo.
func _apply_live() -> void:
	if _live_config != null and _is_playing(_shown):
		BalanceService.table_for(_shown).apply(_live_config, _playing_night)


## Devolve as chaves das linhas que só valem ao recomeçar a noite.
func _restart_keys() -> Array[String]:
	var keys: Array[String] = []
	for section: String in RESTART_ONLY:
		for field_name: StringName in RESTART_ONLY[section]:
			keys.append("%s.%s" % [section, field_name])
	return keys


## Devolve onde "Salvar" grava a tabela mostrada, como caminho do sistema.
func _save_location() -> String:
	return ProjectSettings.globalize_path(BalanceService.save_path(_shown.id))


## Marca a tabela como alterada e, se a célula é da noite em jogo, aplica a coluna nos valores
## vivos.
func _on_grid_cell_changed(_key: String, night: int) -> void:
	BalanceService.mark_changed(_shown.id)
	if night == _playing_night:
		_apply_live()
