# Oficina Automotiva — Implementação em Dart

Implementação das classes do diagrama de classes do grupo (Aula 9).

```
lib/src/
  constantes.dart          tamanhoPlaca, simboloMoeda
  models/
    responsavel.dart
    veiculo.dart
    atendimento.dart       classe entregue como totalmente implementada
    item_atendimento.dart
    tipo_trabalho.dart
    situacao.dart          enum com as transições permitidas
```

## Regras implementadas

- A placa do veículo e a data de entrada do atendimento não mudam após a criação, nem via `copyWith()`.
- A situação do atendimento só muda por transições válidas: aberto → em andamento → aguardando peça ⇄ em andamento → concluído.
- O valor padrão de um tipo de trabalho pode ser reajustado; itens já registrados mantêm o valor cobrado.
- O total do atendimento é calculado a partir dos itens.
- Um atendimento não pode ser concluído sem pelo menos um trabalho.
- `toMap()`/`fromMap()` usam os nomes de coluna do modelo relacional e reconstroem os relacionamentos (responsável → veículos → atendimentos → itens).

## Executar

```
dart pub get
dart run
dart test
```
