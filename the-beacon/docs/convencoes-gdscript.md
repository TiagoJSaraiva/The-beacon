# Convenções de GDScript

Base: guia de estilo oficial do Godot 4. Formatação é responsabilidade do `gdformat`; este documento cobre o que a ferramenta não decide.

## Nomes

| Elemento | Padrão | Exemplo |
|---|---|---|
| Arquivo `.gd` / `.tscn` | snake_case | `player_controller.gd` |
| `class_name`, nó | PascalCase | `class_name HealthComponent`, nó `HurtBox` |
| Função, variável | snake_case | `apply_damage()`, `max_speed` |
| Membro privado | prefixo `_` | `_velocity_buffer`, `_on_timer_timeout()` |
| Constante, valor de enum | CONSTANT_CASE | `const MAX_JUMPS := 2`, `State.FALLING` |
| Enum | PascalCase | `enum State { IDLE, RUNNING }` |
| Sinal | snake_case, passado | `health_changed`, `died` |
| Handler de sinal | `_on_<emissor>_<sinal>` | `_on_hurt_box_area_entered` |
| Ação de input | snake_case semântico | `move_left`, `jump`, `attack` |

## Ordem dentro do script

1. `@tool`, `class_name`, `extends`
2. `##` comentário de documentação da classe
3. `signal`
4. `enum`
5. `const`
6. `@export` vars
7. vars públicas
8. vars privadas (`_`)
9. `@onready` vars
10. `_init()`, `_enter_tree()`, `_ready()`
11. demais virtuais (`_process`, `_physics_process`, `_input`, `_unhandled_input`...)
12. métodos públicos
13. métodos privados
14. classes internas

## Tipagem

```gdscript
var speed: float = 200.0
var jumps_left := MAX_JUMPS            # := só quando o tipo é óbvio pelo lado direito
var targets: Array[Enemy] = []
var scores: Dictionary[String, int] = {}

func apply_damage(amount: int, source: Node2D) -> void:
	pass

func is_alive() -> bool:
	return _health > 0
```

- Nunca `var x = ...` sem tipo.
- `:=` é aceito apenas com literal ou construtor à direita (`:= 2`, `:= Vector2.ZERO`, `:= Timer.new()`).
- Use `as` com verificação ao converter: `var enemy := body as Enemy` seguido de `if enemy == null: return`.

## Godot 3 → Godot 4 (nunca usar a coluna da esquerda)

| Godot 3 | Godot 4 |
|---|---|
| `export var x` | `@export var x: int` |
| `onready var n = $N` | `@onready var n: Node2D = $N` |
| `yield(obj, "sig")` | `await obj.sig` |
| `connect("sig", self, "_m")` | `sig.connect(_m)` |
| `emit_signal("sig", a)` | `sig.emit(a)` |
| `KinematicBody2D` | `CharacterBody2D` |
| `move_and_slide(vel, up)` | `velocity = vel` + `move_and_slide()` |
| `instance()` | `instantiate()` |
| `setget` | `var x: int: set = _set_x, get = _get_x` |
| `tool` | `@tool` |

## Referências a nós

- `@onready var sprite: Sprite2D = $Sprite2D` para filhos diretos.
- Nós usados de longe dentro da mesma cena: marque como nome único e use `%NomeUnico`.
- Proibido: caminhos longos (`$A/B/C/D`), `get_parent().get_parent()`, `get_node()` com string montada.

## Comunicação entre nós

- **Call down, signal up**: pai chama métodos dos filhos; filho emite sinais que o pai escuta.
- Irmãos se comunicam pelo pai ou por sinais, nunca por referência direta.
- Autoloads só para estado genuinamente global (save, configurações, transição de cena). Cada novo autoload exige nota em `docs/decisoes/`.

## Valores e configuração

- `@export` para valores ajustáveis por instância (velocidade de um inimigo específico).
- Constantes em script de configuração para valores globais compartilhados.
- Nenhum número mágico no meio da lógica.

## Física e processamento

- Movimento e física em `_physics_process(delta)`; visual e UI em `_process(delta)`.
- `velocity` de `CharacterBody2D` é em unidades por segundo: `move_and_slide()` já aplica o `delta`. Acelerações (`velocity.y += gravity * delta`) e deslocamentos manuais (`position += dir * speed * delta`) multiplicam por `delta`.
- Camadas de colisão nomeadas em Project Settings e documentadas em `docs/arquitetura.md`.

## Comentários

- `##` para documentar classes e métodos públicos (aparece na ajuda do editor).
- `#` comum só para explicar **por quê**: uma regra de design, um contorno de bug, um valor não óbvio.
- Nada de comentário que repete o código.
