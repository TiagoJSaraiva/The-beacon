extends GdUnitTestSuite
## Teste de fumaça: confirma que o gdUnit4 roda pela linha de comando.
## Pode ser apagado quando existirem testes reais em test/unit.


func test_smoke() -> void:
	assert_int(1 + 1).is_equal(2)
