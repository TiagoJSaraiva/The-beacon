class_name LoopingSound
extends AudioStreamPlayer3D
## Som 3D que se repete enquanto ativo (zumbido, alarme, toque do rádio). O loop é feito
## aqui para não depender das opções de import de cada .wav.

var is_active: bool = false


## Liga o fim do som ao reinício do loop.
func _ready() -> void:
	finished.connect(_on_finished)


## Inicia ou para o som. Repetir o estado atual não reinicia a reprodução.
func set_active(active: bool) -> void:
	if is_active == active:
		return
	is_active = active
	if active:
		play()
	else:
		stop()


## Toca de novo enquanto o som estiver ativo.
func _on_finished() -> void:
	if is_active:
		play()
