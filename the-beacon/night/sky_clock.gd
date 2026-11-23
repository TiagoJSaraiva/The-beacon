class_name SkyClock
extends Node
## Leva a hora da noite ao céu (`Sky3D`): a lua e as estrelas andam conforme o relógio do jogo, de
## 20h às 6h. O relógio próprio da Sky3D fica desligado na cena.

@export var sky: Sky3D
@export var night_director: NightDirector


## Passa a acompanhar cada minuto do relógio da noite.
func _ready() -> void:
	night_director.time_changed.connect(_on_time_changed)


## Põe o céu na hora atual do relógio da noite (0 a 24, como o `current_time` da Sky3D).
func _on_time_changed(_display_text: String) -> void:
	if night_director.clock != null:
		sky.current_time = night_director.clock.clock_hour()
