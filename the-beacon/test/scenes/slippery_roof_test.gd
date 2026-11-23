extends GdUnitTestSuite
## O telhado invisível sobre as máquinas: o jogador e o galão soltos em cima do gerador de emergência
## escorregam até o chão. Física: só faixas de valores.

const LEVEL := "res://test/scenes/fixtures/flat_level.tscn"
const GENERATOR := "res://power/emergency_generator.tscn"
const JERRYCAN := "res://fuel/jerrycan.tscn"
const GENERATOR_POSITION := Vector3(4.0, 0.0, 0.0)
## Soltura do jogador sobre uma das águas. Bem na cumeeira, a ponta redonda da cápsula ainda se
## equilibra (a até ~0,25 m dela), mas ela fica acima do alcance do pulo.
const PLAYER_DROP_OFFSET := Vector3(0.1, 2.4, 0.4)
## Soltura do galão quase na cumeeira: a caixa dele tomba para um dos lados.
const JERRYCAN_DROP_OFFSET := Vector3(-0.1, 2.4, -0.03)
## Abaixo disso, o corpo está no chão, não no topo da máquina (0,97 m).
const FLOOR_HEIGHT := 0.6


func test_player_and_jerrycan_slide_off_the_generator_top() -> void:
	var runner := scene_runner(LEVEL)
	var level: Node3D = runner.scene()
	var player: Player = runner.find_child("Player")
	var generator: Node3D = load(GENERATOR).instantiate()
	level.add_child(generator)
	generator.global_position = GENERATOR_POSITION
	var jerrycan: Jerrycan = load(JERRYCAN).instantiate()
	level.add_child(jerrycan)
	await runner.simulate_frames(5)

	player.global_position = GENERATOR_POSITION + PLAYER_DROP_OFFSET
	jerrycan.drop(GENERATOR_POSITION + JERRYCAN_DROP_OFFSET, Vector3.ZERO)
	await runner.simulate_frames(180)

	assert_float(player.global_position.y).is_less(FLOOR_HEIGHT)
	assert_float(jerrycan.global_position.y).is_less(FLOOR_HEIGHT)
