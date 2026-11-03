class_name SettingsPanel
extends VBoxContainer
## Opções do jogo (GDD 15.2): volumes, sensibilidade do olhar e a página de controles
## (decisão 0018). Usado no menu principal e no menu de pausa; cada mudança vale na hora e
## é gravada ao voltar.

signal back_requested

@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _sensitivity_slider: HSlider = %SensitivitySlider
@onready var _general: Control = %General
@onready var _controls_button: Button = %ControlsButton
@onready var _controls_panel: ControlsPanel = %ControlsPanel


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
	_controls_panel.back_requested.connect(go_back_from_subpage)


## Mostra os valores atuais (o outro painel pode ter mudado algo) e volta à página geral.
func refresh() -> void:
	_show_general()
	_master_slider.set_value_no_signal(Settings.state.master_volume)
	_music_slider.set_value_no_signal(Settings.state.music_volume)
	_sfx_slider.set_value_no_signal(Settings.state.sfx_volume)
	_sensitivity_slider.set_value_no_signal(Settings.state.sensitivity_scale)


func focus_first() -> void:
	_master_slider.grab_focus()


## Numa subpágina (controles), volta à página geral e diz que tratou o pedido.
func go_back_from_subpage() -> bool:
	if not _controls_panel.visible:
		return false
	_show_general()
	_controls_button.grab_focus()
	return true


func _show_general() -> void:
	_general.visible = true
	_controls_panel.visible = false


func _on_controls_button_pressed() -> void:
	_general.visible = false
	_controls_panel.visible = true
	_controls_panel.refresh()
	_controls_panel.focus_first()


func _on_back_button_pressed() -> void:
	Settings.save()
	back_requested.emit()
