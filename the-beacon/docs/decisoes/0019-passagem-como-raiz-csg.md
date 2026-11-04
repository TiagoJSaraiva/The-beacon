# 0019 — Passagem com o buraco na raiz da cena

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O buraco de cada passagem era um `CSGBox3D` na cena do farol, e a porta ou o alçapão era outra instância, em outro ponto da árvore. Mover um sem o outro os desalinhava. Um `Node3D` agrupando os dois não resolve: um CSG de subtração só corta o pai se for filho direto dele.

## Decisão
- A raiz de `entrance_door.tscn` e de `trapdoor.tscn` é o próprio buraco: um `CSGBox3D` de subtração, com a estrutura física e os interativos como filhos.
- `EntranceDoor` é filho direto de `Shell`; `Trapdoor`, de `UpperFloor`. Dentro desses pais, mover o nó leva o buraco e a estrutura juntos.
- Nada se move na raiz durante o jogo: a folha da porta e o painel do alçapão animam nos próprios nós, então o CSG não é recalculado.

## Alternativas descartadas
- **Script `@tool` copiando a posição da porta para um buraco separado**: mais código de editor e risco de dessincronizar.
- **Parede modelada com as aberturas**: exigiria refazer a casca a cada ajuste, o que não combina com o greybox.

## Consequências
Só existe uma posição para ajustar em cada passagem. Em troca, as duas cenas dependem do pai CSG: abertas sozinhas, mostram um bloco cinza no editor, e trocar o pai faz o buraco parar de cortar. O que fica fora da cena (`DoorInside`, `DoorCamera`, `DoorView`, fendas acima da porta) não acompanha a passagem.
