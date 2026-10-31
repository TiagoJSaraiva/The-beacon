# 0001 — GDScript com tipagem estática obrigatória

- **Data**: 2026-10
- **Status**: aceita

## Contexto
O código é escrito em grande parte por agentes de IA e lido e revisado pelo desenvolvedor. Erros precisam aparecer antes de rodar o jogo.

## Decisão
GDScript 2.0 com tipagem estática em variáveis, parâmetros, retornos e coleções.

## Alternativas descartadas
- **C#**: considerado; o desenvolvedor escolheu GDScript para este projeto. Implicaria build .NET e o executável .NET do Godot.
- **GDScript sem tipos**: erros só aparecem em runtime e o código fica mais difícil de ler.

## Consequências
A análise do Godot (etapa de parse do check) passa a detectar erros de tipo. Código um pouco mais verboso.
