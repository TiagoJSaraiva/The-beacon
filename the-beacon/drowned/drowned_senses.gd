class_name DrownedSenses
extends RefCounted
## O que o Afogado sabe neste instante: o diretor preenche o estado do farol e o próprio
## Afogado preenche percepção e chegada ao alvo.

var threat: float = 0.0
var door_broken: bool = false
var hose_broken: bool = false
var generator_broken: bool = false
var trapdoor_state: Trapdoor.State = Trapdoor.State.CLOSED
var player_in_reach: bool = false
var player_in_kill_range: bool = false
var arrived: bool = false
