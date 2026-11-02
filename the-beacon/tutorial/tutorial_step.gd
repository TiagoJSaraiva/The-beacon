class_name TutorialStep
extends Resource
## Um passo do tutorial: o texto que aparece na HUD na primeira vez que a situação acontece.

## Deve ser um dos ids de `TutorialDirector.KNOWN_STEPS`, que liga o passo à situação.
@export var id: StringName = &""
@export_multiline var text: String = ""
