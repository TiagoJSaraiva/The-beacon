class_name DebugPanel
extends CanvasLayer
## Painel de debug (decisão 0024): a ação `debug_menu` (Y) abre e fecha durante a noite. A
## simulação continua rodando; "Pausar simulação" congela o `World` enquanto o painel estiver
## aberto. Roda com `process_mode = ALWAYS`, para responder com o `World` congelado.

## O painel abriu (true) ou fechou (false). O `Game` trava o jogador enquanto está aberto.
signal opened_changed(opened: bool)
## O testador pediu para recomeçar a noite (mesmo `RunState`, valores editados).
signal restart_night_requested
## O testador pediu para jogar a noite dada do plantão (a primeira é 1).
signal night_jump_requested(night: int)

## Largura do painel estreito; a aba Tabela usa a tela inteira.
const NARROW_WIDTH := 480.0

## O nó que a caixa "Pausar simulação" congela.
@export var world: Node3D
@export var night_director: NightDirector
@export var event_director: EventDirector
@export var lighthouse: Lighthouse
@export var fog: FogSystem
@export var fog_visuals: FogVisuals
@export var boats: BoatDirector
@export var drowned: DrownedDirector
@export var figurehead: FigureheadDirector
@export var player: Player

## Desligado fora da simulação (fim de noite, morte, vitória). Desligar fecha o painel.
var enabled: bool = true:
	set = _set_enabled

## Verdadeiro só enquanto o próprio painel mantém o `World` congelado, para não descongelar o que
## o `Game` congelou.
var _froze_world: bool = false
## Abas na ordem em que a leitura do topo as mostra.
var _tabs: Array[DebugTab] = []

@onready var _frame: PanelContainer = %Frame
@onready var _tabs_container: TabContainer = %Tabs
@onready var _pause_check: CheckBox = %PauseCheck
@onready var _readout: Label = %Readout
@onready var _night_tab: NightTab = %NightTab
@onready var _lighthouse_tab: LighthouseTab = %LighthouseTab
@onready var _fog_tab: FogTab = %FogTab
@onready var _threats_tab: ThreatsTab = %ThreatsTab
@onready var _player_tab: PlayerTab = %PlayerTab
@onready var _balance_tab: BalanceTab = %BalanceTab


## Começa escondido, repassa os pedidos de recomeçar a noite e de ir para outra noite da aba Noite
## e alarga o painel na aba Tabela.
func _ready() -> void:
	visible = false
	_tabs = [_night_tab, _lighthouse_tab, _fog_tab, _threats_tab, _player_tab, _balance_tab]
	_pause_check.toggled.connect(_on_pause_check_toggled)
	_night_tab.restart_night_requested.connect(restart_night_requested.emit)
	_night_tab.night_jump_requested.connect(night_jump_requested.emit)
	_tabs_container.tab_changed.connect(_on_tabs_tab_changed)


## Atualiza a leitura de estado do topo enquanto o painel está aberto.
func _process(_delta: float) -> void:
	if not visible:
		return
	var lines := PackedStringArray()
	for tab: DebugTab in _tabs:
		var text: String = tab.readout()
		if not text.is_empty():
			lines.append(text)
	_readout.text = "\n".join(lines)


## Abre com `debug_menu`, se o modo debug estiver ativo, o painel habilitado e a árvore não
## estiver pausada pelo menu de pausa. Aberto, `debug_menu`, `pause` e `ui_cancel` fecham.
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		if (
			event.is_action_pressed("debug_menu")
			and enabled
			and DebugMode.is_active()
			and not get_tree().paused
		):
			get_viewport().set_input_as_handled()
			open()
		return
	if (
		event.is_action_pressed("debug_menu")
		or event.is_action_pressed("pause")
		or event.is_action_pressed("ui_cancel")
	):
		get_viewport().set_input_as_handled()
		close()


## Monta as abas com os sistemas ligados por `@export`, a aba Noite com as noites do plantão e a
## aba Tabela com o catálogo, a dificuldade em jogo, os valores vivos da noite (`night_config`) e a
## noite atual do plantão.
func setup(
	catalog: DifficultyCatalog,
	difficulty: DifficultyConfig,
	night_config: DifficultyConfig,
	run: RunState
) -> void:
	_night_tab.setup(night_director, event_director, run.total_nights)
	_lighthouse_tab.setup(lighthouse)
	_fog_tab.setup(fog, fog_visuals)
	_threats_tab.setup(boats, drowned, figurehead)
	_player_tab.setup(player, lighthouse)
	_balance_tab.setup(catalog, difficulty, night_config, run.current_night)


## Mostra o painel, com a simulação rodando, e emite `opened_changed`.
func open() -> void:
	if visible:
		return
	visible = true
	_pause_check.set_pressed_no_signal(false)
	opened_changed.emit(true)


## Esconde o painel, descongela o `World` se foi ele quem congelou e emite `opened_changed`.
func close() -> void:
	if not visible:
		return
	visible = false
	_set_world_frozen(false)
	opened_changed.emit(false)


## Habilita ou desabilita a abertura; desabilitar fecha o painel aberto.
func _set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		close()


## Congela ou descongela o `World`. Só descongela o que o próprio painel congelou.
func _set_world_frozen(frozen: bool) -> void:
	if world == null or frozen == _froze_world:
		return
	_froze_world = frozen
	world.process_mode = Node.PROCESS_MODE_DISABLED if frozen else Node.PROCESS_MODE_INHERIT


## Ocupa a tela inteira com a aba Tabela e volta à largura estreita nas outras.
func _on_tabs_tab_changed(_tab: int) -> void:
	var wide: bool = _tabs_container.get_current_tab_control().is_ancestor_of(_balance_tab)
	_frame.anchor_left = 0.0 if wide else 1.0
	_frame.offset_left = 0.0 if wide else -NARROW_WIDTH


## Aplica a caixa "Pausar simulação".
func _on_pause_check_toggled(pressed: bool) -> void:
	_set_world_frozen(pressed)
