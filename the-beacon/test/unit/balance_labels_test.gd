extends GdUnitTestSuite
## Nomes em português da tabela de balanceamento: toda linha de toda dificuldade tem nome, e
## nenhum nome sobra ou se repete.

const DIFFICULTY_PATHS: Array[String] = [
	"res://config/difficulties/easy.tres",
	"res://config/difficulties/medium.tres",
	"res://config/difficulties/hard.tres",
]


func _all_row_keys() -> Array[String]:
	var keys: Array[String] = []
	for path: String in DIFFICULTY_PATHS:
		var difficulty: DifficultyConfig = load(path)
		for row: BalanceTable.Row in BalanceTable.from_difficulty(difficulty).rows:
			if row.key not in keys:
				keys.append(row.key)
	return keys


func test_every_table_row_has_a_label() -> void:
	var missing: Array[String] = []
	for key: String in _all_row_keys():
		if not BalanceLabels.LABELS.has(key):
			missing.append(key)

	# Mensagem de falha: acrescente o nome do campo novo em BalanceLabels.LABELS.
	assert_array(missing).is_empty()


func test_no_label_is_left_without_a_row() -> void:
	var keys: Array[String] = _all_row_keys()
	var orphans: Array[String] = []
	for key: String in BalanceLabels.LABELS:
		if key not in keys:
			orphans.append(key)

	assert_array(orphans).is_empty()


func test_labels_are_not_repeated() -> void:
	var seen: Dictionary[String, String] = {}
	var repeated: Array[String] = []
	for key: String in BalanceLabels.LABELS:
		var label: String = BalanceLabels.LABELS[key]
		if seen.has(label):
			repeated.append("%s = %s" % [seen[label], key])
		seen[label] = key

	assert_array(repeated).is_empty()


func test_unknown_key_falls_back_to_the_key() -> void:
	assert_str(BalanceLabels.label_for("fog.campo_novo")).is_equal("fog.campo_novo")
	assert_str(BalanceLabels.label_for("time.night_start_hour")).is_equal(
		"Hora de início da noite (h)"
	)
