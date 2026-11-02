class_name SettingsState
extends RefCounted
## Preferências do jogador (GDD 15.2): volumes de 0 a 1 e escala da sensibilidade do mouse.
## Vídeo e controles estão fora do MVP.

const MIN_VOLUME := 0.0
const MAX_VOLUME := 1.0
const MIN_SENSITIVITY_SCALE := 0.25
const MAX_SENSITIVITY_SCALE := 3.0

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var sensitivity_scale: float = 1.0


func to_dict() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"sensitivity_scale": sensitivity_scale,
	}


## Valores fora da faixa (arquivo editado à mão) são trazidos para dentro dela.
func from_dict(data: Dictionary) -> void:
	master_volume = _volume(data.get("master_volume", master_volume))
	music_volume = _volume(data.get("music_volume", music_volume))
	sfx_volume = _volume(data.get("sfx_volume", sfx_volume))
	sensitivity_scale = clampf(
		float(data.get("sensitivity_scale", sensitivity_scale)),
		MIN_SENSITIVITY_SCALE,
		MAX_SENSITIVITY_SCALE
	)


static func _volume(value: Variant) -> float:
	return clampf(float(value), MIN_VOLUME, MAX_VOLUME)
