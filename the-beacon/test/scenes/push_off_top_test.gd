extends GdUnitTestSuite
## O empurrão no topo das máquinas embaixo da escada (`PushOffTop`): o jogador e o galão parados
## em cima do gerador principal e do tanque são levados à borda mais próxima e caem no chão.
## Física: só faixas de valores.

const LEVEL := "res://test/scenes/fixtures/flat_level.tscn"
const GENERATOR := "res://power/main_generator.tscn"
const TANK := "res://fuel/fuel_tank.tscn"
const JERRYCAN := "res://fuel/jerrycan.tscn"
const GENERATOR_POSITION := Vector3(4.0, 0.0, 0.0)
## Centro do topo do gerador (1,19 × 1,18), em relação à cena dele.
const GENERATOR_TOP := Vector3(0.0, 1.03, 0.0)
## Meia largura do gerador em X: passando disso, o corpo já saiu de cima dele.
const GENERATOR_HALF_X := 0.595
const TANK_POSITION := Vector3(-6.0, 0.0, 0.0)
## Ponto mais alto do tanque deitado (raio 1,39 m, eixo em Z), em relação à cena dele.
const TANK_TOP := Vector3(-0.1675, 3.2, 0.109)
## Soltura do jogador perto do centro do topo, um pouco para +X: a borda mais próxima é a de +X.
const PLAYER_DROP_OFFSET := Vector3(0.2, 0.1, 0.0)
## Soltura do galão do outro lado, longe do jogador.
const JERRYCAN_DROP_OFFSET := Vector3(-0.2, 0.1, 0.3)
## Abaixo disso, o corpo está no chão, não no topo da máquina.
const FLOOR_HEIGHT := 0.6
const SETTLE_FRAMES := 240


func test_player_and_jerrycan_are_pushed_off_the_main_generator() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	var jerrycan: Jerrycan = await _setup(runner, GENERATOR, GENERATOR_POSITION)
	var top: Vector3 = GENERATOR_POSITION + GENERATOR_TOP

	player.teleport(top + PLAYER_DROP_OFFSET)
	jerrycan.drop(top + JERRYCAN_DROP_OFFSET, Vector3.ZERO)
	await runner.simulate_frames(SETTLE_FRAMES)

	assert_float(player.global_position.y).is_less(FLOOR_HEIGHT)
	assert_float(jerrycan.global_position.y).is_less(FLOOR_HEIGHT)
	# Caiu pela borda mais próxima (+X), não por outra.
	assert_float(player.global_position.x).is_greater(GENERATOR_POSITION.x + GENERATOR_HALF_X)


func test_player_and_jerrycan_are_pushed_off_the_fuel_tank() -> void:
	var runner := scene_runner(LEVEL)
	var player: Player = runner.find_child("Player")
	var jerrycan: Jerrycan = await _setup(runner, TANK, TANK_POSITION)
	var top: Vector3 = TANK_POSITION + TANK_TOP

	player.teleport(top + PLAYER_DROP_OFFSET)
	jerrycan.drop(top + JERRYCAN_DROP_OFFSET, Vector3.ZERO)
	await runner.simulate_frames(SETTLE_FRAMES)

	assert_float(player.global_position.y).is_less(FLOOR_HEIGHT)
	assert_float(jerrycan.global_position.y).is_less(FLOOR_HEIGHT)


## Põe a máquina e um galão no nível plano e devolve o galão.
func _setup(runner: GdUnitSceneRunner, machine_path: String, at: Vector3) -> Jerrycan:
	var level: Node3D = runner.scene()
	var machine: Node3D = load(machine_path).instantiate()
	level.add_child(machine)
	machine.global_position = at
	var jerrycan: Jerrycan = load(JERRYCAN).instantiate()
	level.add_child(jerrycan)
	await runner.simulate_frames(5)
	return jerrycan
