extends Node
## Autoload Settings: carrega, aplica e grava as preferências do jogador, editadas tanto no
## menu principal quanto no menu de pausa (decisão 0012), incluindo os controles
## remapeáveis (decisão 0018).

signal changed

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "settings"
const CONTROLS_SECTION := "controls"
const BUS_MASTER := &"Master"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"

var state: SettingsState = SettingsState.new()
var bindings: InputBindings = InputBindings.new()


## Carrega as preferências e aplica os volumes e as ligações ao abrir o jogo.
func _ready() -> void:
	_load()
	_apply_volumes()
	_apply_bindings()


## Muda o volume geral (0 a 1) na hora. Só grava com `save`.
func set_master_volume(volume: float) -> void:
	state.master_volume = volume
	_on_state_edited()


## Muda o volume da música (0 a 1) na hora. Só grava com `save`.
func set_music_volume(volume: float) -> void:
	state.music_volume = volume
	_on_state_edited()


## Muda o volume dos efeitos (0 a 1) na hora. Só grava com `save`.
func set_sfx_volume(volume: float) -> void:
	state.sfx_volume = volume
	_on_state_edited()


## Muda a escala da sensibilidade do olhar. Só grava com `save`.
func set_sensitivity_scale(scale: float) -> void:
	state.sensitivity_scale = scale
	_on_state_edited()


## Dá a tecla física à ação e aplica no InputMap. Só grava com `save`.
func set_key_binding(action: StringName, physical_keycode: int) -> void:
	bindings.bind_key(action, physical_keycode)
	_on_bindings_edited()


## Dá o botão de controle à ação e aplica no InputMap. Só grava com `save`.
func set_button_binding(action: StringName, button: int) -> void:
	bindings.bind_button(action, button)
	_on_bindings_edited()


## Volta os controles ao padrão e aplica no InputMap. Só grava com `save`.
func reset_bindings() -> void:
	bindings.reset_to_defaults()
	_on_bindings_edited()


## Grava as preferências e os controles em `user://settings.cfg`.
func save() -> void:
	var file := ConfigFile.new()
	var values: Dictionary = state.to_dict()
	for key: String in values:
		file.set_value(SECTION, key, values[key])
	var controls: Dictionary = bindings.to_dict()
	for key: String in controls:
		file.set_value(CONTROLS_SECTION, key, controls[key])
	var error: Error = file.save(SETTINGS_PATH)
	if error != OK:
		push_error("Não foi possível gravar %s: %s" % [SETTINGS_PATH, error])


## Lê o arquivo de configurações. Sem arquivo, mantém os valores padrão.
func _load() -> void:
	var file := ConfigFile.new()
	if file.load(SETTINGS_PATH) != OK:
		return
	state.from_dict(_read_section(file, SECTION))
	bindings.from_dict(_read_section(file, CONTROLS_SECTION))


## Devolve as chaves de uma seção do arquivo; vazio se ela não existir.
func _read_section(file: ConfigFile, section: String) -> Dictionary:
	var values: Dictionary = {}
	if not file.has_section(section):
		return values
	for key: String in file.get_section_keys(section):
		values[key] = file.get_value(section, key)
	return values


## Limita os valores editados, aplica os volumes e emite `changed`.
func _on_state_edited() -> void:
	# Passa pelo dicionário para aplicar os mesmos limites de um arquivo carregado.
	state.from_dict(state.to_dict())
	_apply_volumes()
	changed.emit()


## Aplica as ligações no InputMap e emite `changed`.
func _on_bindings_edited() -> void:
	_apply_bindings()
	changed.emit()


## Troca só os eventos de tecla e de botão das ações remapeáveis; os de eixo ficam.
func _apply_bindings() -> void:
	for action: StringName in InputBindings.KEYBOARD_ACTIONS:
		var key := InputEventKey.new()
		key.physical_keycode = bindings.keys[action] as Key
		_replace_event(action, "InputEventKey", key)
	for action: StringName in InputBindings.JOYPAD_ACTIONS:
		var button := InputEventJoypadButton.new()
		button.button_index = bindings.buttons[action] as JoyButton
		_replace_event(action, "InputEventJoypadButton", button)


## Troca os eventos da classe dada na ação pelo evento novo. Ação inexistente é ignorada.
func _replace_event(action: StringName, event_class: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		return
	for existing: InputEvent in InputMap.action_get_events(action):
		if existing.is_class(event_class):
			InputMap.action_erase_event(action, existing)
	InputMap.action_add_event(action, event)


## Aplica os três volumes aos buses de áudio.
func _apply_volumes() -> void:
	_apply_bus_volume(BUS_MASTER, state.master_volume)
	_apply_bus_volume(BUS_MUSIC, state.music_volume)
	_apply_bus_volume(BUS_SFX, state.sfx_volume)


## Aplica o volume (0 a 1) ao bus; em zero, ele fica mudo. Bus inexistente é ignorado.
func _apply_bus_volume(bus_name: StringName, volume: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, volume <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))
