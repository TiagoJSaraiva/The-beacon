class_name BalanceLabels
extends RefCounted
## Nomes em português das linhas da tabela de balanceamento (decisão 0031). A chave é a mesma da
## `BalanceTable` (`<seção>.<campo>`). Um `@export` novo precisa de nome aqui: o teste
## `balance_labels_test.gd` reprova linha sem nome.

const LABELS: Dictionary[String, String] = {
	# Noite
	"difficulty.event_chance_multiplier": "Multiplicador da chance dos eventos",
	"time.night_start_hour": "Hora de início da noite (h)",
	"time.night_end_hour": "Hora de fim da noite (h)",
	"time.real_seconds_per_game_hour": "Segundos reais por hora do jogo (s)",
	# Quebras
	"repair.lamp_replace_seconds": "Troca da lâmpada: duração (s)",
	"repair.lamp_burnout_cooldown_seconds": "Lâmpada: intervalo até queimar de novo (s)",
	"repair.machine_repair_seconds": "Conserto da casa de máquinas: duração (s)",
	"repair.machine_breakdown_cooldown_seconds":
	"Casa de máquinas: intervalo até quebrar de novo (s)",
	"events/lamp_burnout.window_start_hour": "Lâmpada queima: início da janela (h)",
	"events/lamp_burnout.window_end_hour": "Lâmpada queima: fim da janela (h)",
	"events/lamp_burnout.check_interval_seconds": "Lâmpada queima: intervalo entre sorteios (s)",
	"events/lamp_burnout.chance_per_check": "Lâmpada queima: chance por sorteio",
	"events/lamp_burnout.max_per_night": "Lâmpada queima: máximo por noite",
	"events/machine_breakdown.window_start_hour": "Casa de máquinas quebra: início da janela (h)",
	"events/machine_breakdown.window_end_hour": "Casa de máquinas quebra: fim da janela (h)",
	"events/machine_breakdown.check_interval_seconds":
	"Casa de máquinas quebra: intervalo entre sorteios (s)",
	"events/machine_breakdown.chance_per_check": "Casa de máquinas quebra: chance por sorteio",
	"events/machine_breakdown.max_per_night": "Casa de máquinas quebra: máximo por noite",
	# Energia
	"power.generator_capacity": "Gerador de emergência: capacidade",
	"power.generator_start_fuel": "Gerador de emergência: combustível inicial",
	"power.generator_consumption_per_second": "Gerador de emergência: consumo por segundo",
	"power.jerrycan_capacity": "Galão: capacidade",
	"power.jerrycan_slot_fill_seconds": "Galão: tempo para encher no tanque (s)",
	"power.jerrycan_pour_seconds": "Galão: tempo para despejar (s)",
	# Nevoeiro
	"fog.near_advance": "Estágio perto: avanço",
	"fog.ground_floor_advance": "Estágio térreo: avanço",
	"fog.stairs_advance": "Estágio escada: avanço",
	"fog.trapdoor_advance": "Estágio alçapão: avanço",
	"fog.cabin_advance": "Estágio cabine: avanço",
	"fog.beam_cover_advance": "Estágio feixe coberto: avanço",
	"fog.start_advance": "Avanço com que o nevoeiro surge",
	"fog.route_center": "Centro do trecho coberto da rota",
	"fog.max_route_coverage": "Maior parte da rota coberta",
	"fog.idle_grace_seconds": "Farol parado: tempo até o nevoeiro surgir (s)",
	"fog.advance_per_second": "Farol parado: avanço por segundo",
	"fog.recoil_ratio": "Recuo imediato ao religar (fração)",
	"fog.unblock_seconds": "Feixe coberto: tempo operando até recuar (s)",
	"fog.recede_per_second": "Recuo por segundo com o farol operando",
	"events/fog.window_start_hour": "Nevoeiro surge: início da janela (h)",
	"events/fog.window_end_hour": "Nevoeiro surge: fim da janela (h)",
	"events/fog.check_interval_seconds": "Nevoeiro surge: intervalo entre sorteios (s)",
	"events/fog.chance_per_check": "Nevoeiro surge: chance por sorteio",
	"events/fog.max_per_night": "Nevoeiro surge: máximo por noite",
	# Barcos
	"boat.crossing_seconds": "Barco: tempo de travessia (s)",
	"boat.max_simultaneous_boats": "Barcos ao mesmo tempo: máximo",
	"events/boat.window_start_hour": "Barco chama: início da janela (h)",
	"events/boat.window_end_hour": "Barco chama: fim da janela (h)",
	"events/boat.check_interval_seconds": "Barco chama: intervalo entre sorteios (s)",
	"events/boat.chance_per_check": "Barco chama: chance por sorteio",
	"events/boat.max_per_night": "Barco chama: máximo por noite",
	# Afogado
	"drowned.approach_base_per_second": "Aproximação: subida base por segundo",
	"drowned.approach_per_point_per_second": "Aproximação: subida extra por ponto, por segundo",
	"drowned.approach_recede_per_second": "Aproximação: descida por segundo",
	"drowned.move_speed": "Velocidade do Afogado (m/s)",
	"drowned.perception_range": "Alcance de percepção (m)",
	"drowned.occlusion_penalty": "Distância extra por obstáculo (m)",
	"drowned.kill_distance": "Distância de ataque (m)",
	"drowned.ladder_climb_speed": "Velocidade na escada de mão (m/s)",
	"drowned.tire_seconds": "Tempo batendo antes de cansar (s)",
	"drowned.rest_seconds": "Tempo descansando (s)",
	"drowned.footstep_audible_distance": "Distância em que os passos se ouvem (m)",
	"trapdoor.resistance_seconds": "Alçapão: tempo de batidas até abrir (s)",
	"trapdoor.latch_toggle_seconds": "Trinco: tempo para ligar ou desligar (s)",
	"trapdoor.latch_relock_cooldown_seconds": "Trinco: espera para ligar depois do nevoeiro (s)",
	"trapdoor.reclose_cooldown_seconds": "Alçapão: espera para fechar depois de aberto (s)",
	# Carranca
	"figurehead.max_simultaneous": "Carrancas ao mesmo tempo: máximo",
	"figurehead.spawn_interval_seconds": "Intervalo entre aparições (s)",
	"figurehead.min_spawn_distance": "Distância mínima do jogador ao surgir (m)",
	"figurehead.trigger_range": "Alcance do pulo (m)",
	"figurehead.blind_seconds": "Duração da cegueira (s)",
	"figurehead.blinds_before_knockdown": "Cegueiras antes de derrubar",
	"figurehead.knockdown_seconds": "Duração da derrubada (s)",
	"figurehead.dissolve_seconds": "Tempo sob a lanterna para dissolver (s)",
	"figurehead.respawn_after_destroyed_seconds": "Volta depois de dissolvida (s)",
	"figurehead.respawn_after_attack_seconds": "Volta depois de atacar (s)",
	# Jogador
	"flashlight.battery_seconds": "Lanterna: bateria do plantão (s)",
	"flashlight.beam_range": "Lanterna: alcance do feixe (m)",
	"flashlight.beam_half_angle_degrees": "Lanterna: meio-ângulo do feixe (°)",
	"fall.sprint_block_height": "Queda que bloqueia a corrida (m)",
	"fall.fatal_height": "Queda fatal (m)",
	"fall.sprint_block_seconds": "Duração do bloqueio da corrida (s)",
}


## Devolve o nome em português da linha da tabela, ou a própria chave se não houver nome.
static func label_for(key: String) -> String:
	return LABELS.get(key, key)
