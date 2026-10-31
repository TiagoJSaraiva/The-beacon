class_name PoweredLights
extends Node3D
## Grupo de luzes que acendem só com energia (iluminação do andar de cima).


func set_powered(powered: bool) -> void:
	for child: Node in get_children():
		var light := child as Light3D
		if light != null:
			light.visible = powered
