class_name TutorialContent
extends Resource
## Textos do tutorial (GDD 9.1). Mudar um texto ou a duração não exige mexer em código.

@export var steps: Array[TutorialStep] = []
## Quanto tempo cada texto fica na tela antes do próximo da fila.
@export var message_seconds: float = 8.0


func step_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for step: TutorialStep in steps:
		ids.append(step.id)
	return ids


func text_for(step_id: StringName) -> String:
	for step: TutorialStep in steps:
		if step.id == step_id:
			return step.text
	return ""
