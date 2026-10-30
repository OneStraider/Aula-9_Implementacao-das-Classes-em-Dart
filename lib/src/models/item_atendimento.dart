import '../constantes.dart';
import 'tipo_trabalho.dart';

/// Trabalho executado dentro de um atendimento (parte da composição).
///
/// O valor cobrado é copiado do tipo no momento da criação, então reajustes
/// futuros do [TipoTrabalho] não alteram atendimentos já registrados.
class ItemAtendimento {
  final TipoTrabalho tipo;
  final double valorCobrado;
  String? _observacao;

  ItemAtendimento({required TipoTrabalho tipo, String? observacao})
      : this._(
          tipo: tipo,
          valorCobrado: tipo.valorPadrao,
          observacao: observacao,
        );

  ItemAtendimento._({
    required this.tipo,
    required this.valorCobrado,
    String? observacao,
  }) : _observacao = _normalizarObservacao(observacao) {
    if (!valorCobrado.isFinite || valorCobrado < 0) {
      throw ArgumentError('Valor cobrado inválido: $valorCobrado');
    }
  }

  /// Reconstrói o item mantendo o valor cobrado gravado, e não o valor atual
  /// do tipo.
  factory ItemAtendimento.fromMap(Map<String, dynamic> map) =>
      ItemAtendimento._(
        tipo: TipoTrabalho.fromMap(
            Map<String, dynamic>.from(map['tipo_trabalho'] as Map)),
        valorCobrado: (map['valor_cobrado'] as num).toDouble(),
        observacao: map['observacao'] as String?,
      );

  String? get observacao => _observacao;
  set observacao(String? valor) => _observacao = _normalizarObservacao(valor);

  String descricaoItem() {
    final obs = _observacao == null ? '' : ' ($_observacao)';
    return '${tipo.descricao}: '
        '$simboloMoeda ${valorCobrado.toStringAsFixed(2)}$obs';
  }

  /// Tipo e valor cobrado formam o registro histórico do item; só a
  /// observação pode ser trocada na cópia.
  ItemAtendimento copyWith({String? observacao}) => ItemAtendimento._(
        tipo: tipo,
        valorCobrado: valorCobrado,
        observacao: observacao ?? _observacao,
      );

  Map<String, dynamic> toMap() => {
        'tipo_trabalho': tipo.toMap(),
        'valor_cobrado': valorCobrado,
        'observacao': _observacao,
      };

  static String? _normalizarObservacao(String? observacao) {
    final obs = observacao?.trim();
    return (obs == null || obs.isEmpty) ? null : obs;
  }

  @override
  String toString() => 'ItemAtendimento(${descricaoItem()})';
}
