extends Node
## Autoload Settings: carrega, aplica e grava as preferências do jogador, editadas tanto no
## menu principal quanto no menu de pausa (decisão 0012).

signal changed

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "settings"
const BUS_MASTER := &"Master"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"

var state: SettingsState = SettingsState.new()


func _ready() -> void:
	_load()
	_apply_volumes()


func set_master_volume(volume: float) -> void:
	state.master_volume = volume
	_on_state_edited()


func set_music_volume(volume: float) -> void:
	state.music_volume = volume
	_on_state_edited()


func set_sfx_volume(volume: float) -> void:
	state.sfx_volume = volume
	_on_state_edited()


func set_sensitivity_scale(scale: float) -> void:
	state.sensitivity_scale = scale
	_on_state_edited()


func save() -> void:
	var file := ConfigFile.new()
	var values: Dictionary = state.to_dict()
	for key: String in values:
		file.set_value(SECTION, key, values[key])
	var error: Error = file.save(SETTINGS_PATH)
	if error != OK:
		push_error("Não foi possível gravar %s: %s" % [SETTINGS_PATH, error])


func _load() -> void:
	var file := ConfigFile.new()
	if file.load(SETTINGS_PATH) != OK:
		return
	var values: Dictionary = {}
	for key: String in file.get_section_keys(SECTION):
		values[key] = file.get_value(SECTION, key)
	state.from_dict(values)


func _on_state_edited() -> void:
	# Passa pelo dicionário para aplicar os mesmos limites de um arquivo carregado.
	state.from_dict(state.to_dict())
	_apply_volumes()
	changed.emit()


func _apply_volumes() -> void:
	_apply_bus_volume(BUS_MASTER, state.master_volume)
	_apply_bus_volume(BUS_MUSIC, state.music_volume)
	_apply_bus_volume(BUS_SFX, state.sfx_volume)


func _apply_bus_volume(bus_name: StringName, volume: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, volume <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))
