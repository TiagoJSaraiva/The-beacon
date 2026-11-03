class_name SettingsPanel
extends VBoxContainer
## Opções do jogo (GDD 15.2): volumes e sensibilidade do mouse. Usado no menu principal e no
## menu de pausa; cada mudança vale na hora e é gravada ao voltar.

signal back_requested

@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _sensitivity_slider: HSlider = %SensitivitySlider


func _ready() -> void:
	for slider: HSlider in [_master_slider, _music_slider, _sfx_slider]:
		slider.min_value = SettingsState.MIN_VOLUME
		slider.max_value = SettingsState.MAX_VOLUME
	_sensitivity_slider.min_value = SettingsState.MIN_SENSITIVITY_SCALE
	_sensitivity_slider.max_value = SettingsState.MAX_SENSITIVITY_SCALE
	refresh()
	_master_slider.value_changed.connect(Settings.set_master_volume)
	_music_slider.value_changed.connect(Settings.set_music_volume)
	_sfx_slider.value_changed.connect(Settings.set_sfx_volume)
	_sensitivity_slider.value_changed.connect(Settings.set_sensitivity_scale)


## Mostra os valores atuais (o outro painel pode ter mudado algo).
func refresh() -> void:
	_master_slider.set_value_no_signal(Settings.state.master_volume)
	_music_slider.set_value_no_signal(Settings.state.music_volume)
	_sfx_slider.set_value_no_signal(Settings.state.sfx_volume)
	_sensitivity_slider.set_value_no_signal(Settings.state.sensitivity_scale)


func focus_first() -> void:
	_master_slider.grab_focus()


func _on_back_button_pressed() -> void:
	Settings.save()
	back_requested.emit()
