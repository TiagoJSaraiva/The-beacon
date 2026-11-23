extends GdUnitTestSuite
## Alçapão: o painel não é usado por quem está em cima dele (seria arremessado), abre mirando o vão
## de longe e, aberto, rente à parede, ainda pode ser fechado de dentro da cabine.

const GAME := "res://game/game.tscn"
## Em pé sobre o painel fechado, no centro do vão.
const ON_PANEL := Vector3(4.7, 10.85, 0.16)
## Em pé no piso da cabine, ao lado do vão, olhando para a parede onde o painel fica aberto.
const CABIN_SPOT := Vector3(3.4, 10.8, 0.16)
const LOOK_DOWN_DEGREES := -20.0
## Em pé no piso da cabine a mais de 1 m da borda do painel, olhando o vão de cima.
const FAR_SPOT := Vector3(2.6, 10.8, 0.16)
const FAR_LOOK_DOWN_DEGREES := -35.0
## Passo fixo dos frames simulados, para as esperas valerem em tempo de jogo (o giro do painel é
## animado) e não dependerem da velocidade da máquina.
const FRAME_MS := 20


func test_panel_is_used_from_beside_it_but_not_from_on_top() -> void:
	var runner := scene_runner(GAME)
	var player: Player = runner.find_child("Player")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)
	player.invulnerable = true

	var panel: Interactable = lighthouse.trapdoor.find_child("PanelInteractable")
	player.teleport(ON_PANEL)
	await runner.simulate_frames(10, FRAME_MS)
	assert_bool(panel.can_be_used(false, player)).is_false()

	# Abrir mirando o painel fechado não é o que se testa aqui; o teste dispara o interativo.
	panel.interacted.emit()
	player.teleport(CABIN_SPOT)
	# De frente para +X, onde fica a dobradiça.
	player.rotation.y = -PI / 2.0
	var head: Node3D = player.find_child("Head")
	head.rotation.x = deg_to_rad(LOOK_DOWN_DEGREES)
	# Espera o painel terminar de abrir.
	await runner.simulate_frames(50, FRAME_MS)
	assert_int(lighthouse.trapdoor.state).is_equal(Trapdoor.State.OPEN)

	runner.simulate_action_press("interact")
	await runner.simulate_frames(10, FRAME_MS)
	runner.simulate_action_release("interact")
	await runner.simulate_frames(10, FRAME_MS)
	assert_int(lighthouse.trapdoor.state).is_equal(Trapdoor.State.CLOSED)


func test_panel_opens_when_aimed_from_a_step_away() -> void:
	var runner := scene_runner(GAME)
	var player: Player = runner.find_child("Player")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)
	player.invulnerable = true

	player.teleport(FAR_SPOT)
	# De frente para +X, para o vão.
	player.rotation.y = -PI / 2.0
	var head: Node3D = player.find_child("Head")
	head.rotation.x = deg_to_rad(FAR_LOOK_DOWN_DEGREES)
	await runner.simulate_frames(10, FRAME_MS)

	runner.simulate_action_press("interact")
	await runner.simulate_frames(10, FRAME_MS)
	runner.simulate_action_release("interact")
	await runner.simulate_frames(10, FRAME_MS)
	assert_int(lighthouse.trapdoor.state).is_equal(Trapdoor.State.OPEN)
