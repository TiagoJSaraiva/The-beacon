# 0006 — Referência entre componentes por @export tipado

- **Data**: 2026-10
- **Status**: aceita

## Contexto
As convenções proíbem referência direta entre irmãos: a comunicação passa pelo pai ou por sinais. Com o código dividido em componentes (`HealthComponent`, `HurtBox`...), isso obriga o pai a repassar toda interação entre eles, gerando código repetido em cada entidade.

## Decisão
Um componente pode referenciar outro componente da mesma cena por `@export` tipado (`@export var health: HealthComponent`), atribuído no editor. Fora desse caso, a regra de irmãos continua valendo. Um componente nunca depende do script do pai.

## Alternativas descartadas
- **Pai conecta tudo**: mais desacoplado, mas cada entidade repete a mesma fiação entre componentes.
- **Busca por caminho (`$"../Health"`, `get_node`)**: dependência escondida no código e quebra ao renomear ou mover nós.

## Consequências
A dependência fica visível e tipada no inspetor, e o componente é reutilizável em qualquer cena que forneça a dependência. Um `@export` não atribuído precisa ser tratado (aviso em `_ready()` ou `_get_configuration_warnings()`).
