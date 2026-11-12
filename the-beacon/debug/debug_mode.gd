class_name DebugMode
extends RefCounted
## Liga o painel de debug (decisão 0024). Só vale em build de debug (editor e testes): um
## export nunca traz o painel, mesmo com a constante ligada.

## Troque para false para jogar no editor sem o painel.
const ENABLED: bool = true


## Diz se o painel de debug pode ser aberto nesta execução.
static func is_active() -> bool:
	return ENABLED and OS.is_debug_build()
