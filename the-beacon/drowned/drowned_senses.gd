class_name DrownedSenses
extends RefCounted
## O que o Afogado sabe neste instante: o diretor preenche o estado do alçapão e o próprio
## Afogado preenche percepção e chegada ao alvo.

var trapdoor_state: Trapdoor.State = Trapdoor.State.CLOSED
var trapdoor_latched: bool = false
var player_in_reach: bool = false
var player_in_kill_range: bool = false
var arrived: bool = false
