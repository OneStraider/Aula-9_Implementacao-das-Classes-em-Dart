import '../constantes.dart';

/// Serviço oferecido pela oficina. A descrição é fixa; o valor padrão pode
/// ser reajustado.
class TipoTrabalho {
  final int id;
  final String descricao;
  double _valorPadrao;

  TipoTrabalho({
    required this.id,
    required String descricao,
    required double valorPadrao,
  })  : descricao = descricao.trim(),
        _valorPadrao = _validarValor(valorPadrao) {
    if (this.descricao.isEmpty) {
      throw ArgumentError('A descrição do tipo de trabalho é obrigatória.');
    }
  }

  factory TipoTrabalho.fromMap(Map<String, dynamic> map) => TipoTrabalho(
        id: map['id_tipo_trabalho'] as int,
        descricao: map['descricao'] as String,
        valorPadrao: (map['valor_padrao'] as num).toDouble(),
      );

  double get valorPadrao => _valorPadrao;

  /// Itens de atendimento já registrados mantêm o valor cobrado na época.
  void reajustarValor(double novoValor) {
    _valorPadrao = _validarValor(novoValor);
  }

  /// O id identifica o tipo e não é trocado na cópia.
  TipoTrabalho copyWith({String? descricao, double? valorPadrao}) =>
      TipoTrabalho(
        id: id,
        descricao: descricao ?? this.descricao,
        valorPadrao: valorPadrao ?? _valorPadrao,
      );

  Map<String, dynamic> toMap() => {
        'id_tipo_trabalho': id,
        'descricao': descricao,
        'valor_padrao': _valorPadrao,
      };

  static double _validarValor(double valor) {
    if (!valor.isFinite || valor < 0) {
      throw ArgumentError('Valor inválido: $valor');
    }
    return valor;
  }

  @override
  String toString() => 'TipoTrabalho(id: $id, descricao: $descricao, '
      'valorPadrao: $simboloMoeda ${_valorPadrao.toStringAsFixed(2)})';
}
