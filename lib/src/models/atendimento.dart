import '../constantes.dart';
import 'item_atendimento.dart';
import 'situacao.dart';
import 'tipo_trabalho.dart';
import 'veiculo.dart';

/// Atendimento de um veículo na oficina.
///
/// Regras:
/// - a data de entrada e o veículo (e, portanto, a placa) não mudam;
/// - a situação só muda por [alterarSituacao], seguindo [Situacao.proximas];
/// - o total é sempre calculado a partir dos itens;
/// - não é possível concluir sem pelo menos um trabalho;
/// - depois de concluído, os itens não podem mais ser alterados.
class Atendimento {
  final int id;
  final DateTime dataEntrada;
  final String problemaRelatado;
  final Veiculo veiculo;
  Situacao _situacao;
  DateTime? _dataConclusao;
  final List<ItemAtendimento> _itens;

  /// Abre um novo atendimento: situação [Situacao.aberto], sem itens e com a
  /// data de entrada igual ao momento da criação.
  Atendimento({
    required int id,
    required Veiculo veiculo,
    required String problemaRelatado,
  }) : this._(
          id: id,
          veiculo: veiculo,
          problemaRelatado: problemaRelatado,
          dataEntrada: DateTime.now(),
          situacao: Situacao.aberto,
          dataConclusao: null,
          itens: const [],
        );

  /// Construtor completo, usado para reconstruir e copiar. Recusa estados que
  /// as regras de negócio não permitem.
  Atendimento._({
    required this.id,
    required this.veiculo,
    required String problemaRelatado,
    required this.dataEntrada,
    required Situacao situacao,
    required DateTime? dataConclusao,
    required List<ItemAtendimento> itens,
  })  : problemaRelatado = problemaRelatado.trim(),
        _situacao = situacao,
        _dataConclusao = dataConclusao,
        _itens = List.of(itens) {
    if (this.problemaRelatado.isEmpty) {
      throw ArgumentError('O problema relatado é obrigatório.');
    }
    if (_itens.map((i) => i.tipo.id).toSet().length != _itens.length) {
      throw ArgumentError('Um mesmo trabalho não pode aparecer duas vezes.');
    }
    if (situacao == Situacao.concluido) {
      if (_itens.isEmpty) {
        throw StateError(
            'Atendimento concluído deve ter ao menos um trabalho.');
      }
      if (dataConclusao == null) {
        throw ArgumentError('Atendimento concluído exige data de conclusão.');
      }
      if (dataConclusao.isBefore(dataEntrada)) {
        throw ArgumentError('A conclusão não pode ser anterior à entrada.');
      }
    } else if (dataConclusao != null) {
      throw ArgumentError('Só atendimentos concluídos têm data de conclusão.');
    }
  }

  /// Reconstrói o atendimento com seus itens. O veículo é recebido como
  /// objeto, já que o mapa guarda apenas o id dele.
  factory Atendimento.fromMap(Map<String, dynamic> map, Veiculo veiculo) {
    if (map['id_veiculo'] != veiculo.id) {
      throw ArgumentError(
          'O id_veiculo do mapa não corresponde ao veículo informado.');
    }
    final dataConclusao = map['data_conclusao'] as String?;
    return Atendimento._(
      id: map['id_atendimento'] as int,
      veiculo: veiculo,
      problemaRelatado: map['problema_relatado'] as String,
      dataEntrada: DateTime.parse(map['data_entrada'] as String),
      situacao: Situacao.values.byName(map['situacao'] as String),
      dataConclusao:
          dataConclusao == null ? null : DateTime.parse(dataConclusao),
      itens: [
        for (final item in (map['itens'] as List?) ?? const [])
          ItemAtendimento.fromMap(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }

  Situacao get situacao => _situacao;
  DateTime? get dataConclusao => _dataConclusao;

  /// Somente leitura: alterações passam por [adicionarTrabalho] e
  /// [removerTrabalho].
  List<ItemAtendimento> get itens => List.unmodifiable(_itens);

  void adicionarTrabalho(TipoTrabalho tipo, {String? observacao}) {
    _exigirNaoConcluido();
    if (_itens.any((i) => i.tipo.id == tipo.id)) {
      throw StateError(
          'O trabalho "${tipo.descricao}" já está no atendimento.');
    }
    _itens.add(ItemAtendimento(tipo: tipo, observacao: observacao));
  }

  void removerTrabalho(TipoTrabalho tipo) {
    _exigirNaoConcluido();
    final quantidadeAntes = _itens.length;
    _itens.removeWhere((i) => i.tipo.id == tipo.id);
    if (_itens.length == quantidadeAntes) {
      throw StateError(
          'O trabalho "${tipo.descricao}" não está no atendimento.');
    }
  }

  double calcularValorTotal() =>
      _itens.fold(0.0, (total, item) => total + item.valorCobrado);

  void alterarSituacao(Situacao nova) {
    if (!_situacao.podeMudarPara(nova)) {
      throw StateError(
          'Não é possível passar de "${_situacao.rotulo}" para "${nova.rotulo}".');
    }
    if (nova == Situacao.concluido && _itens.isEmpty) {
      throw StateError('Não é possível concluir um atendimento sem trabalhos.');
    }
    _situacao = nova;
    if (nova == Situacao.concluido) _dataConclusao = DateTime.now();
  }

  bool estaConcluido() => _situacao == Situacao.concluido;

  String resumo() {
    final texto = StringBuffer()
      ..writeln('Atendimento #$id - ${veiculo.identificacao()}')
      ..writeln('Problema: $problemaRelatado')
      ..writeln('Entrada: ${_formatarData(dataEntrada)}')
      ..writeln('Situação: ${_situacao.rotulo}');
    final conclusao = _dataConclusao;
    if (conclusao != null) {
      texto.writeln('Conclusão: ${_formatarData(conclusao)}');
    }
    for (final item in _itens) {
      texto.writeln('  - ${item.descricaoItem()}');
    }
    texto.write(
        'Total: $simboloMoeda ${calcularValorTotal().toStringAsFixed(2)}');
    return texto.toString();
  }

  /// Id, veículo e data de entrada nunca são trocados na cópia. Uma nova
  /// situação passa pelas mesmas validações de [alterarSituacao], então a
  /// cópia não pula etapas nem conclui sem trabalhos.
  Atendimento copyWith({String? problemaRelatado, Situacao? situacao}) {
    final copia = Atendimento._(
      id: id,
      veiculo: veiculo,
      problemaRelatado: problemaRelatado ?? this.problemaRelatado,
      dataEntrada: dataEntrada,
      situacao: _situacao,
      dataConclusao: _dataConclusao,
      itens: _itens,
    );
    if (situacao != null && situacao != _situacao) {
      copia.alterarSituacao(situacao);
    }
    return copia;
  }

  /// O veículo vai só pelo id; os itens (composição) vão aninhados.
  Map<String, dynamic> toMap() => {
        'id_atendimento': id,
        'id_veiculo': veiculo.id,
        'data_entrada': dataEntrada.toIso8601String(),
        'problema_relatado': problemaRelatado,
        'situacao': _situacao.name,
        'data_conclusao': _dataConclusao?.toIso8601String(),
        'itens': _itens.map((i) => i.toMap()).toList(),
      };

  void _exigirNaoConcluido() {
    if (estaConcluido()) {
      throw StateError(
          'Atendimento concluído não pode ter os trabalhos alterados.');
    }
  }

  static String _formatarData(DateTime data) {
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
        '${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
  }

  @override
  String toString() => 'Atendimento(id: $id, placa: ${veiculo.placa}, '
      'situacao: ${_situacao.rotulo}, itens: ${_itens.length}, '
      'total: $simboloMoeda ${calcularValorTotal().toStringAsFixed(2)})';
}
