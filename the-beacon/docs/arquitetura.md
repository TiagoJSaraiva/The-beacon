# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
_A definir: gênero, loop principal, escopo do MVP._

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
assets/             arte, áudio e fontes compartilhados
autoload/           singletons (cada um com decisão registrada)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
_Nenhuma ainda. Formato: cena → nó raiz (tipo) → filhos relevantes e propósito._

## Autoloads
_Nenhum._

## Sinais entre sistemas
_Nenhum. Formato: `emissor.sinal` → `receptor._handler` — propósito._

## Input map
_Nenhuma ação ainda. Usar nomes semânticos: `move_left`, `move_right`, `jump`..._

## Camadas de colisão
_Nenhuma nomeada ainda. Formato: número — nome — quem está nela / quem detecta._
