# 0026 — Escada de mão: zona de agarrar e link de navegação

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O alçapão foi encostado na parede e a rampa que ligava a escada em caracol a ele saiu. A escada em caracol não pode chegar até o piso da cabine (10.8 m): sob a laje (fundo em 10.5) não sobra altura para a cabeça. A ligação passa a ser uma escada de mão de 2.4 m, do patamar (8.4 m) ao vão. O `CharacterBody3D` não sobe superfícies verticais, e a navmesh não liga dois pisos separados por uma parede vertical.

## Decisão
- **Jogador**: a escada (`Ladder`) tem uma `ClimbZone` numa camada própria (`ladders`). O jogador tem um componente `LadderClimber` (`Area3D`) que a detecta e calcula o movimento agarrado com regras puras (`LadderRules`): sem gravidade, frente sobe e trás desce (olhando para baixo, invertido), saída no topo seguindo em frente.
- **Afogado**: um `NavigationLink3D` (`LadderLink`, bidirecional e sempre ligado) une o patamar ao piso da cabine. Ao chegar ao link (`NavigationAgent3D.link_reached`), ele faz um percurso cinemático fixo (`LadderTraversal`): sobe na vertical e anda na horizontal no nível de cima, ou o inverso ao descer, sem física. Só começa com o alçapão aberto. Subindo, se o alçapão fechar, volta à entrada.
- Como na decisão 0009, a passagem não muda a navmesh: quem respeita o alçapão é a regra do Afogado.

## Alternativas descartadas
- **Afogado subindo pela física, com a gravidade desligada**: bateria no painel fechado e ficaria pendurado em estados intermediários.
- **Ligar e desligar o link com o alçapão**: contraria a decisão 0009 (os caminhos sempre passam pelas barreiras) e deixaria o Afogado sem caminho até o jogador da cabine, em vez de esperar no pé da escada.

## Consequências
Outra escada de mão é só mais uma instância de `Ladder` (com um `NavigationLink3D` se o Afogado tiver de usá-la). Na escada, o Afogado não colide com nada nem percebe obstáculos no caminho. O ponto onde ele bate no alçapão (`TrapdoorBelow`, no pé da escada) é provisório (`sistemas/afogados.md`).
