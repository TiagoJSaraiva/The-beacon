extends GdUnitTestSuite
## Disparo manual de eventos (painel de debug): respeita quem trata o evento e avisa o disparo.

var _fired: int = 0


func test_trigger_now_respects_can_trigger_and_emits() -> void:
	var director: EventDirector = auto_free(EventDirector.new())
	var allowed: Array[bool] = [false]
	director.register(&"boat", func() -> bool: return allowed[0], _on_fire)
	monitor_signals(director)

	assert_bool(director.trigger_now(&"boat")).is_false()
	assert_bool(director.trigger_now(&"unknown")).is_false()
	assert_int(_fired).is_equal(0)

	allowed[0] = true
	assert_bool(director.trigger_now(&"boat")).is_true()
	assert_int(_fired).is_equal(1)
	await assert_signal(director).is_emitted("event_triggered", [&"boat"])
	assert_array(director.registered_events()).contains_exactly([&"boat"])


func _on_fire() -> void:
	_fired += 1
