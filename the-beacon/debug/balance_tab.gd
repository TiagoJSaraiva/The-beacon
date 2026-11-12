class_name BalanceTab
extends VBoxContainer
## Aba "Balanceamento" do painel de debug: edita ao vivo os valores da dificuldade da noite,
## exporta no console o que difere do `.tres` e restaura os originais. As edições mudam o recurso
## em memória (valem até fechar o jogo) e nunca são gravadas em disco.

## O testador pediu para recomeçar a noite com os valores atuais.
signal restart_night_requested

## Campos que não fazem sentido mudar no meio do plantão (o `RunState` já os copiou).
const HIDDEN_FIELDS: Array[StringName] = [&"nights", &"tutorial_enabled"]
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
const SECTION_COLOR := Color(0.85, 0.65, 0.2)

var _sections: Array[ConfigFields.Section] = []
var _original_sections: Array[ConfigFields.Section] = []
var _editors: Array[ConfigEditor] = []
var _status: Label


## Monta os botões, a legenda e uma lista de campos por seção da dificuldade. Guarda uma cópia
## do `.tres` lida do disco para comparar e restaurar.
func setup(difficulty: DifficultyConfig) -> void:
	_add_buttons()
	_sections = ConfigFields.sections(difficulty)
	var original := (
		ResourceLoader.load(difficulty.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		as DifficultyConfig
	)
	if original != null:
		_original_sections = ConfigFields.sections(original)
	for section: ConfigFields.Section in _sections:
		_add_section(section)


## Imprime no console as diferenças para o `.tres`, por seção, e resume na aba.
func export_changes() -> void:
	if _original_sections.size() != _sections.size():
		_status.text = "Sem o .tres original para comparar."
		return
	var count: int = 0
	print("== Debug: valores alterados (original -> atual) ==")
	for index: int in _sections.size():
		var lines: PackedStringArray = ConfigFields.differences(
			_sections[index].resource, _original_sections[index].resource
		)
		for line: String in lines:
			print("%s.%s" % [_sections[index].label, line])
		count += lines.size()
	_status.text = "%d valor(es) alterado(s), listados no console." % count


## Volta todos os campos aos valores do `.tres` e atualiza as linhas.
func restore_originals() -> void:
	if _original_sections.size() != _sections.size():
		_status.text = "Sem o .tres original para restaurar."
		return
	for index: int in _sections.size():
		ConfigFields.copy_values(_original_sections[index].resource, _sections[index].resource)
	for editor: ConfigEditor in _editors:
		editor.refresh()
	_status.text = "Valores originais restaurados."


## Cria a linha de botões e o texto de status com a legenda da marca.
func _add_buttons() -> void:
	var row := HBoxContainer.new()
	_add_button(row, "Exportar alterações", export_changes)
	_add_button(row, "Restaurar originais", restore_originals)
	_add_button(row, "Recomeçar a noite", restart_night_requested.emit)
	add_child(row)
	_status = Label.new()
	_status.text = "%s = vale ao recomeçar a noite" % ConfigEditor.RESTART_MARK.strip_edges()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)


## Acrescenta à linha um botão que chama `action`.
func _add_button(row: HBoxContainer, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	row.add_child(button)


## Acrescenta o título da seção e o editor dos campos dela.
func _add_section(section: ConfigFields.Section) -> void:
	var title := Label.new()
	title.text = section.label
	title.add_theme_color_override("font_color", SECTION_COLOR)
	add_child(title)
	var restart_only: Array[StringName] = []
	restart_only.assign(RESTART_ONLY.get(section.label, []))
	var editor := ConfigEditor.new()
	editor.build(section.resource, HIDDEN_FIELDS, restart_only)
	add_child(editor)
	_editors.append(editor)
