extends GdUnitTestSuite
## Com o nevoeiro dentro do farol e um ponto de Afogado, ele arromba a porta, aparece do
## lado de dentro e sobe pela navmesh do interior até o alçapão.

const GAME := "res://game/game.tscn"


func test_drowned_bursts_in_and_heads_to_the_trapdoor() -> void:
	var runner := scene_runner(GAME)
	var fog: FogSystem = runner.find_child("FogSystem")
	var drowned_director: DrownedDirector = runner.find_child("DrownedDirector")
	var lighthouse: Lighthouse = runner.find_child("Lighthouse")
	await runner.simulate_frames(5)

	drowned_director.add_drowned_point()
	fog.start()
	fog.state.advance = 0.5
	drowned_director.approach.level = 0.99
	monitor_signals(drowned_director)
	await assert_signal(drowned_director).wait_until(3000).is_emitted("drowned_entered")

	var drowned: Drowned = drowned_director.find_child("Drowned", true, false)
	assert_object(drowned).is_not_null()
	var entry: Vector3 = lighthouse.drowned_entry_point()
	assert_float(drowned.global_position.distance_to(entry)).is_less(0.5)

	# A escada em caracol dá a volta: a distância em linha reta não serve de progresso.
	var trapdoor_below: Vector3 = lighthouse.drowned_targets()[DrownedBrain.Target.TRAPDOOR_BELOW]
	var path: PackedVector3Array = NavigationServer3D.map_get_path(
		drowned.get_world_3d().navigation_map, entry, trapdoor_below, true
	)
	assert_int(path.size()).is_greater(1)
	assert_float(path[path.size() - 1].distance_to(trapdoor_below)).is_less(1.0)
	await runner.simulate_frames(120)
	assert_float(drowned.global_position.distance_to(entry)).is_greater(2.0)
