class_name FogState
extends RefCounted
## Nevoeiro (GDD 1.2.10): surge, varia de intensidade enquanto dura e se dissipa aos poucos.
## Intensidade de 0 (sem nevoeiro) a 1.

var config: FogConfig
var is_active: bool = false
var intensity: float = 0.0
var target_intensity: float = 0.0
var remaining_seconds: float = 0.0
var retarget_seconds: float = 0.0


func _init(fog_config: FogConfig) -> void:
	config = fog_config


func start(rng: RandomNumberGenerator) -> void:
	is_active = true
	remaining_seconds = rng.randf_range(config.min_duration_seconds, config.max_duration_seconds)
	_retarget(rng)


func tick(delta: float, rng: RandomNumberGenerator) -> void:
	if is_active:
		remaining_seconds -= delta
		retarget_seconds -= delta
		if remaining_seconds <= 0.0:
			is_active = false
		elif retarget_seconds <= 0.0:
			_retarget(rng)
	var goal: float = target_intensity if is_active else 0.0
	intensity = move_toward(intensity, goal, config.intensity_change_per_second * delta)


## Há nevoeiro em qualquer intensidade: barcos permitidos precisam do feixe.
func is_present() -> bool:
	return intensity > 0.0


## Forte o bastante para cobrir a câmera do farol: surge o Homem de Nevoeiro.
func covers_lighthouse_camera() -> bool:
	return intensity >= config.fog_man_threshold


func _retarget(rng: RandomNumberGenerator) -> void:
	target_intensity = rng.randf_range(config.min_intensity, config.max_intensity)
	retarget_seconds = config.retarget_interval_seconds
