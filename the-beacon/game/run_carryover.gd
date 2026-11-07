class_name RunCarryover
extends Node
## O que passa de uma noite para a outra (decisão 0015): aplica o `RunState` aos sistemas ao
## montar a noite e o recolhe às 06:00. Todo o resto da simulação recomeça do zero.

@export var lighthouse: Lighthouse
@export var player: Player
@export var drowned: DrownedDirector
@export var tutorial: TutorialDirector


## Aplica o estado persistente aos sistemas da noite. O tutorial vem antes da mangueira:
## estourada numa noite anterior, ela não repete o texto.
func apply(run: RunState) -> void:
	tutorial.restore_shown(run.tutorial_shown_ids)
	drowned.drowned_points = run.drowned_points
	if run.hose_burst:
		lighthouse.burst_hose(false)
	player.flashlight.set_battery_seconds(run.flashlight_battery_seconds)


## Copia para o `RunState` o que passa à noite seguinte: pontos de Afogado, mangueira, bateria e
## tutorial.
func capture(run: RunState) -> void:
	run.drowned_points = drowned.drowned_points
	run.hose_burst = lighthouse.is_hose_burst()
	run.flashlight_battery_seconds = player.flashlight.battery.remaining_seconds
	run.tutorial_shown_ids = tutorial.shown_ids()
