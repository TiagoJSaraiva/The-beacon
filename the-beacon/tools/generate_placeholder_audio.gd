extends SceneTree
## Gera os sons placeholder (tons sintéticos) em assets/audio/placeholder/.
## Rodar uma vez, da raiz do projeto:
##   godot --headless --path . --script res://tools/generate_placeholder_audio.gd

const MIX_RATE := 22050
const OUTPUT_DIR := "res://assets/audio/placeholder/"
const AMPLITUDE := 0.4

var _noise: RandomNumberGenerator = RandomNumberGenerator.new()


func _init() -> void:
	_noise.seed = 42
	_save("radio_ring", _tone(900.0, 0.4) + _silence(0.15) + _tone(900.0, 0.4) + _silence(1.0))
	_save("radio_allowed", _tone(600.0, 0.3) + _silence(0.1) + _tone(900.0, 0.45))
	_save(
		"radio_pirate",
		(
			_square(220.0, 0.35)
			+ _silence(0.15)
			+ _square(200.0, 0.35)
			+ _silence(0.15)
			+ _square(180.0, 0.5)
		)
	)
	_save("alarm", _square(440.0, 0.4) + _silence(0.6))
	_save("footstep", _thump(0.14, 90.0) + _silence(0.4))
	_save("bang", _thump(0.3, 55.0))
	_save("generator_hum", _hum(1.0))
	quit()


func _tone(frequency: float, seconds: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for i in int(seconds * MIX_RATE):
		samples.append(sin(TAU * frequency * i / MIX_RATE) * _envelope(i, seconds))
	return samples


func _square(frequency: float, seconds: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for i in int(seconds * MIX_RATE):
		var phase: float = sin(TAU * frequency * i / MIX_RATE)
		samples.append(signf(phase) * 0.6 * _envelope(i, seconds))
	return samples


func _thump(seconds: float, frequency: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count: int = int(seconds * MIX_RATE)
	for i in count:
		var decay: float = pow(1.0 - float(i) / count, 3.0)
		var body: float = sin(TAU * frequency * i / MIX_RATE)
		samples.append((body * 0.8 + _noise.randf_range(-0.3, 0.3)) * decay)
	return samples


func _hum(seconds: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for i in int(seconds * MIX_RATE):
		var t: float = float(i) / MIX_RATE
		samples.append(sin(TAU * 55.0 * t) * 0.6 + sin(TAU * 110.0 * t) * 0.3)
	return samples


func _silence(seconds: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	samples.resize(int(seconds * MIX_RATE))
	return samples


## Rampa curta de entrada e saída para não estalar.
func _envelope(index: int, seconds: float) -> float:
	var fade: float = 0.01 * MIX_RATE
	var count: float = seconds * MIX_RATE
	return clampf(minf(index / fade, (count - index) / fade), 0.0, 1.0)


func _save(sound_name: String, samples: PackedFloat32Array) -> void:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i] * AMPLITUDE, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	var path: String = OUTPUT_DIR + sound_name + ".wav"
	print("%s -> %s" % [path, error_string(stream.save_to_wav(path))])
