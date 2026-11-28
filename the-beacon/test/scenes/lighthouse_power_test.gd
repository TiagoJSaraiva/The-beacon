extends GdUnitTestSuite
## Energia, galão e nevoeiro no farol (decisão 0017): a fonte troca quando a mangueira
## estoura, o galão circula entre slot, mão, chão e gerador de emergência, e o nevoeiro
## bloqueia o feixe e estoura a mangueira.

const LIGHTHOUSE := "res://lighthouse/lighthouse.tscn"


func test_emergency_generator_takes_over_when_hose_bursts() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	await runner.simulate_frames(2)
	monitor_signals(lighthouse)
	lighthouse.beam_control.is_on = true
	lighthouse.beam_control.switched.emit(true)
	await assert_signal(lighthouse).is_emitted("beam_lit_changed", [true])
	assert_bool(lighthouse.emergency_generator.state.in_use).is_false()

	lighthouse.burst_hose()
	await runner.simulate_frames(2)
	assert_bool(lighthouse.main_generator.is_running()).is_false()
	assert_bool(lighthouse.beam.is_lit()).is_true()
	assert_bool(lighthouse.emergency_generator.state.in_use).is_true()

	lighthouse.emergency_generator.state.fuel = 0.0
	await assert_signal(lighthouse).wait_until(1000).is_emitted("beam_lit_changed", [false])


func test_covering_fog_blocks_the_beam_and_inside_fog_bursts_the_hose() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	await runner.simulate_frames(2)
	lighthouse.beam_control.is_on = true
	lighthouse.beam_control.switched.emit(true)

	lighthouse.set_fog_stage(FogStage.Stage.NEAR)
	assert_bool(lighthouse.beam.is_lit()).is_true()
	assert_bool(lighthouse.is_hose_burst()).is_false()

	lighthouse.set_fog_stage(FogStage.Stage.GROUND_FLOOR)
	assert_bool(lighthouse.is_hose_burst()).is_true()

	lighthouse.set_fog_stage(FogStage.Stage.BEAM)
	assert_bool(lighthouse.beam.is_operational()).is_true()
	assert_bool(lighthouse.beam.is_lit()).is_false()

	lighthouse.set_fog_stage(FogStage.Stage.CABIN)
	assert_bool(lighthouse.beam.is_lit()).is_true()


func test_jerrycan_goes_from_slot_to_floor_and_back() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	var jerrycan: Jerrycan = lighthouse.jerrycan
	await runner.simulate_frames(2)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.SLOT)

	# No slot, o ponto de devolução desativado envolve o galão e não pode bloquear a mira.
	monitor_signals(lighthouse)
	await _pick_up_with_ray(runner, lighthouse)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.HAND)
	await assert_signal(lighthouse).is_emitted("jerrycan_carried_changed", [true])

	# Solto no térreo, num vão livre ao lado da casa de máquinas (que ocupa o centro), cai e para
	# no chão.
	lighthouse.drop_jerrycan(Vector3(0.0, 1.0, 3.0), Vector3.ZERO)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.WORLD)
	await runner.simulate_frames(90)
	assert_float(jerrycan.global_position.y).is_between(-0.05, 0.3)

	# Na prateleira vazia, o ponto de devolução exige o galão na mão e também não bloqueia.
	jerrycan.pick_up_requested.emit()
	var shelf_top: Vector3 = lighthouse.fuel_tank.slot.dock_transform().origin
	lighthouse.drop_jerrycan(shelf_top + Vector3.UP * 0.1, Vector3.ZERO)
	await runner.simulate_frames(60)
	await _pick_up_with_ray(runner, lighthouse)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.HAND)

	jerrycan.state.amount = 0.0
	lighthouse.fuel_tank.slot.return_requested.emit()
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.SLOT)
	await runner.simulate_frames(30)
	assert_float(jerrycan.state.amount).is_greater(0.0)

	lighthouse.emergency_generator.state.fuel = 10.0
	var poured_in: float = jerrycan.state.amount
	lighthouse.emergency_generator.refuel_requested.emit()
	assert_float(lighthouse.emergency_generator.state.fuel).is_equal_approx(10.0 + poured_in, 0.001)


func test_only_the_emergency_generator_takes_the_jerrycan() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	await runner.simulate_frames(2)
	assert_object(lighthouse.main_generator.fuel_inlet).is_null()
	assert_object(lighthouse.emergency_generator.fuel_inlet).is_not_null()

	# O despejo sai da boca de combustível e chega ao farol, que transfere o galão.
	lighthouse.emergency_generator.state.fuel = 10.0
	lighthouse.jerrycan.state.amount = 5.0
	lighthouse.emergency_generator.fuel_inlet.pour_completed.emit()
	assert_float(lighthouse.emergency_generator.state.fuel).is_equal_approx(15.0, 0.001)


func test_cabin_gauge_repeats_the_emergency_generator_fuel() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	var gauge_fill: Node3D = lighthouse.cabin_fuel_gauge.find_child("GaugePivot")
	await runner.simulate_frames(2)
	assert_float(gauge_fill.scale.y).is_equal_approx(
		lighthouse.emergency_generator.state.fuel_ratio(), 0.01
	)

	lighthouse.emergency_generator.state.set_fuel_ratio(0.4)
	await runner.simulate_frames(2)
	assert_float(gauge_fill.scale.y).is_equal_approx(0.4, 0.01)

	# Despejar o galão no gerador de baixo sobe também o medidor de cima.
	lighthouse.jerrycan.state.amount = 5.0
	lighthouse.emergency_generator.refuel_requested.emit()
	await runner.simulate_frames(2)
	assert_float(gauge_fill.scale.y).is_greater(0.4)

	lighthouse.emergency_generator.state.fuel = 0.0
	await runner.simulate_frames(2)
	assert_float(gauge_fill.scale.y).is_less(0.01)


func test_ground_and_stair_lights_go_out_when_the_hose_bursts() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	await runner.simulate_frames(2)
	var lower: Array[Node] = lighthouse.lower_lights.find_children("*", "Light3D", true, false)
	var upper: Array[Node] = lighthouse.interior_lights.find_child("UpperLights").find_children(
		"*", "Light3D", true, false
	)
	assert_int(lower.size()).is_greater(0)
	assert_int(upper.size()).is_greater(0)
	assert_bool(lower.all(func(light: Node) -> bool: return (light as Light3D).visible)).is_true()

	lighthouse.burst_hose()
	await runner.simulate_frames(2)
	assert_bool(lighthouse.lower_lights.is_powered()).is_false()
	assert_bool(lower.any(func(light: Node) -> bool: return (light as Light3D).visible)).is_false()
	# A cabine segue iluminada (o que acontece com ela sem combustível é pendência do patrão).
	assert_bool(upper.all(func(light: Node) -> bool: return (light as Light3D).visible)).is_true()


## Mira o galão de cima, como o jogador em pé, e usa a tecla de interagir pelo raio real.
func _pick_up_with_ray(runner: GdUnitSceneRunner, lighthouse: Lighthouse) -> void:
	var center: Vector3 = lighthouse.jerrycan.global_position + Vector3.UP * 0.2
	var ray := InteractionRay.new()
	ray.target_position = Vector3.FORWARD * 2.2
	monitor_signals(ray)
	lighthouse.add_child(ray)
	ray.global_position = center + Vector3(1.2, 1.0, 0.0)
	ray.look_at(center)
	await assert_signal(ray).wait_until(2000).is_emitted("focus_changed", [true])
	runner.simulate_action_press("interact")
	await await_millis(100)
	runner.simulate_action_release("interact")
	ray.queue_free()
