extends GdUnitTestSuite
## Energia e galão no farol (decisão 0017): a fonte troca quando a mangueira estoura, e o
## galão circula entre slot, mão, chão e gerador de emergência.

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


func test_jerrycan_goes_from_slot_to_floor_and_back() -> void:
	var runner := scene_runner(LIGHTHOUSE)
	var lighthouse: Lighthouse = runner.scene()
	var jerrycan: Jerrycan = lighthouse.jerrycan
	await runner.simulate_frames(2)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.SLOT)

	monitor_signals(lighthouse)
	jerrycan.pick_up_requested.emit()
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.HAND)
	await assert_signal(lighthouse).is_emitted("jerrycan_carried_changed", [true])

	# Solto no meio do térreo, cai e para no chão.
	lighthouse.drop_jerrycan(Vector3(0.0, 1.0, 0.0), Vector3.ZERO)
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.WORLD)
	await runner.simulate_frames(90)
	assert_float(jerrycan.global_position.y).is_between(-0.05, 0.3)

	jerrycan.pick_up_requested.emit()
	jerrycan.state.amount = 0.0
	lighthouse.fuel_tank.slot.return_requested.emit()
	assert_int(jerrycan.place).is_equal(Jerrycan.Place.SLOT)
	await runner.simulate_frames(30)
	assert_float(jerrycan.state.amount).is_greater(0.0)

	lighthouse.emergency_generator.state.fuel = 10.0
	var poured_in: float = jerrycan.state.amount
	lighthouse.emergency_generator.refuel_requested.emit()
	assert_float(lighthouse.emergency_generator.state.fuel).is_equal_approx(10.0 + poured_in, 0.001)
