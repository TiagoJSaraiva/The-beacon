extends GdUnitTestSuite
## Regras da animação de locomoção: velocidade local, passo, giro das pernas e velocidade de
## reprodução.


func test_local_velocity_ignores_the_body_rotation() -> void:
	# Corpo virado para +X (giro de -90° em Y): andar para +X é andar para a frente.
	var facing := Basis(Vector3.UP, -PI / 2.0)

	var local: Vector2 = LocomotionRules.local_velocity(Vector3(3.5, 0.0, 0.0), facing)

	assert_float(local.y).is_between(3.4, 3.6)
	assert_float(absf(local.x)).is_less(0.01)


func test_local_velocity_separates_forward_and_side() -> void:
	var forward: Vector2 = LocomotionRules.local_velocity(Vector3(0, 0, -3.0), Basis.IDENTITY)
	var right: Vector2 = LocomotionRules.local_velocity(Vector3(3.0, 0, 0), Basis.IDENTITY)
	var back: Vector2 = LocomotionRules.local_velocity(Vector3(0, 0, 3.0), Basis.IDENTITY)

	assert_float(forward.y).is_between(2.9, 3.1)
	assert_float(right.x).is_between(2.9, 3.1)
	assert_float(back.y).is_between(-3.1, -2.9)


func test_gait_by_speed() -> void:
	assert_int(LocomotionRules.gait(0.0)).is_equal(LocomotionRules.Gait.IDLE)
	assert_int(LocomotionRules.gait(1.5)).is_equal(LocomotionRules.Gait.WALK)
	assert_int(LocomotionRules.gait(3.5)).is_equal(LocomotionRules.Gait.JOG)
	assert_int(LocomotionRules.gait(4.125)).is_equal(LocomotionRules.Gait.JOG)


func test_forward_has_no_leg_yaw_and_is_not_reversed() -> void:
	var local := Vector2(0.0, 3.5)

	assert_bool(LocomotionRules.is_reversed(local, false)).is_false()
	assert_float(LocomotionRules.leg_yaw(local, false)).is_between(-0.01, 0.01)


func test_strafing_turns_the_legs_to_the_side() -> void:
	var right: float = LocomotionRules.leg_yaw(Vector2(3.5, 0.0), false)
	var left: float = LocomotionRules.leg_yaw(Vector2(-3.5, 0.0), false)

	assert_float(right).is_between(PI / 2.0 - 0.01, PI / 2.0 + 0.01)
	assert_float(left).is_between(-PI / 2.0 - 0.01, -PI / 2.0 + 0.01)


func test_walking_back_plays_reversed_with_legs_forward() -> void:
	var local := Vector2(0.0, -3.5)

	var reversed: bool = LocomotionRules.is_reversed(local, false)

	assert_bool(reversed).is_true()
	assert_float(LocomotionRules.leg_yaw(local, reversed)).is_between(-0.01, 0.01)


func test_back_and_right_turns_legs_to_the_left_when_reversed() -> void:
	var local := Vector2(2.5, -2.5)

	var reversed: bool = LocomotionRules.is_reversed(local, false)

	assert_bool(reversed).is_true()
	assert_float(LocomotionRules.leg_yaw(local, reversed)).is_between(-0.8, -0.77)


func test_reversal_has_hysteresis_around_pure_strafe() -> void:
	# Quase de lado, o estado anterior prevalece em vez de alternar a cada quadro.
	var almost_side := Vector2(3.5, -0.2)

	assert_bool(LocomotionRules.is_reversed(almost_side, false)).is_false()
	assert_bool(LocomotionRules.is_reversed(almost_side, true)).is_true()


func test_standing_still_keeps_reversal_and_zero_yaw() -> void:
	assert_bool(LocomotionRules.is_reversed(Vector2.ZERO, true)).is_true()
	assert_float(LocomotionRules.leg_yaw(Vector2.ZERO, true)).is_equal(0.0)


func test_time_scale_follows_speed_within_limits() -> void:
	var jog: float = LocomotionRules.time_scale(LocomotionRules.Gait.JOG, 4.125, false)
	var slow: float = LocomotionRules.time_scale(LocomotionRules.Gait.WALK, 0.2, false)
	var fast: float = LocomotionRules.time_scale(LocomotionRules.Gait.WALK, 10.0, false)
	var back: float = LocomotionRules.time_scale(LocomotionRules.Gait.JOG, 3.5, true)

	assert_float(jog).is_between(0.7, 0.85)
	assert_float(slow).is_equal(LocomotionRules.MIN_TIME_SCALE)
	assert_float(fast).is_equal(LocomotionRules.MAX_TIME_SCALE)
	assert_float(back).is_between(-0.7, -0.6)
	assert_float(LocomotionRules.time_scale(LocomotionRules.Gait.IDLE, 0.0, false)).is_equal(1.0)
