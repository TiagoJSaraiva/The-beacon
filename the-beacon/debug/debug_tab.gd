class_name DebugTab
extends VBoxContainer
## Base das abas do painel de debug: monta títulos, botões, campos e caixas em código e dá ao
## painel as linhas de estado que ele mostra no topo.

const TITLE_COLOR := Color(0.85, 0.65, 0.2)
const SPIN_WIDTH := 110.0

var _status: Label


## Devolve as linhas de estado da aba para o topo do painel. Vazio se a aba não tiver.
func readout() -> String:
	return ""


## Acrescenta um título de seção.
func add_title(text: String) -> void:
	var title := Label.new()
	title.text = text
	title.add_theme_color_override("font_color", TITLE_COLOR)
	add_child(title)


## Acrescenta uma linha (que quebra quando não cabe) com um botão por item de `buttons`, na ordem
## dada: texto do botão → ação.
func add_buttons(buttons: Dictionary[String, Callable]) -> void:
	var row := HFlowContainer.new()
	for text: String in buttons:
		var button := Button.new()
		button.text = text
		button.pressed.connect(buttons[text])
		row.add_child(button)
	add_child(row)


## Acrescenta uma linha com rótulo, SpinBox e um botão que chama `apply(valor)`. Devolve a
## SpinBox, para quem quiser atualizar o valor depois.
func add_value_action(
	label_text: String,
	range_min: float,
	range_max: float,
	step: float,
	value: float,
	button_text: String,
	apply: Callable
) -> SpinBox:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var spin := SpinBox.new()
	spin.custom_minimum_size.x = SPIN_WIDTH
	spin.min_value = range_min
	spin.max_value = range_max
	spin.step = step
	spin.value = value
	row.add_child(spin)
	var button := Button.new()
	button.text = button_text
	button.pressed.connect(func() -> void: apply.call(spin.value))
	row.add_child(button)
	add_child(row)
	return spin


## Acrescenta uma caixa de marcar que chama `on_toggled(marcada)` a cada mudança.
func add_toggle(text: String, pressed: bool, on_toggled: Callable) -> CheckBox:
	var check := CheckBox.new()
	check.text = text
	check.button_pressed = pressed
	check.toggled.connect(on_toggled)
	add_child(check)
	return check


## Acrescenta, uma vez, a linha onde `show_status` escreve o resultado das ações.
func add_status(initial_text: String = "") -> void:
	_status = Label.new()
	_status.text = initial_text
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.modulate = Color(1.0, 1.0, 1.0, 0.75)
	add_child(_status)


## Mostra o resultado de uma ação na linha de status, se a aba tiver uma.
func show_status(text: String) -> void:
	if _status != null:
		_status.text = text
