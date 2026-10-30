import '../constantes.dart';
import 'atendimento.dart';
import 'responsavel.dart';

/// Veículo de um responsável. A placa não muda após a criação; apenas a cor
/// pode ser alterada.
class Veiculo {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final int ano;
  String _cor;
  final Responsavel responsavel;
  final List<Atendimento> _atendimentos = [];

  Veiculo({
    required this.id,
    required String placa,
    required String marca,
    required String modelo,
    required this.ano,
    required String cor,
    required this.responsavel,
  })  : placa = _validarPlaca(placa),
        marca = _validarObrigatorio(marca, 'marca'),
        modelo = _validarObrigatorio(modelo, 'modelo'),
        _cor = _validarObrigatorio(cor, 'cor') {
    if (ano < 1900 || ano > DateTime.now().year + 1) {
      throw ArgumentError('Ano inválido: $ano');
    }
  }

  /// Reconstrói o veículo e seus atendimentos. O responsável é recebido como
  /// objeto, já que o mapa guarda apenas o id dele.
  factory Veiculo.fromMap(Map<String, dynamic> map, Responsavel responsavel) {
    if (map['id_responsavel'] != responsavel.id) {
      throw ArgumentError(
          'O id_responsavel do mapa não corresponde ao responsável informado.');
    }
    final veiculo = Veiculo(
      id: map['id_veiculo'] as int,
      placa: map['placa'] as String,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      ano: map['ano'] as int,
      cor: map['cor'] as String,
      responsavel: responsavel,
    );
    for (final atendimento in (map['atendimentos'] as List?) ?? const []) {
      veiculo.registrarAtendimento(Atendimento.fromMap(
          Map<String, dynamic>.from(atendimento as Map), veiculo));
    }
    return veiculo;
  }

  String get cor => _cor;
  set cor(String valor) => _cor = _validarObrigatorio(valor, 'cor');

  String identificacao() => '$placa - $marca $modelo ($ano, $_cor)';

  void registrarAtendimento(Atendimento atendimento) {
    if (atendimento.veiculo.placa != placa) {
      throw ArgumentError(
          'O atendimento ${atendimento.id} pertence a outro veículo.');
    }
    if (_atendimentos.any((a) => a.id == atendimento.id)) {
      throw StateError('O atendimento ${atendimento.id} já foi registrado.');
    }
    _atendimentos.add(atendimento);
  }

  /// Atendimentos do mais antigo para o mais recente.
  List<Atendimento> historicoAtendimentos() => List.unmodifiable([
        ..._atendimentos
      ]..sort((a, b) => a.dataEntrada.compareTo(b.dataEntrada)));

  /// Id, placa e responsável não são trocados na cópia; os atendimentos são
  /// mantidos.
  Veiculo copyWith({String? marca, String? modelo, int? ano, String? cor}) =>
      Veiculo(
        id: id,
        placa: placa,
        marca: marca ?? this.marca,
        modelo: modelo ?? this.modelo,
        ano: ano ?? this.ano,
        cor: cor ?? _cor,
        responsavel: responsavel,
      ).._atendimentos.addAll(_atendimentos);

  /// O responsável vai só pelo id; os atendimentos vão aninhados.
  Map<String, dynamic> toMap() => {
        'id_veiculo': id,
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'cor': _cor,
        'id_responsavel': responsavel.id,
        'atendimentos': _atendimentos.map((a) => a.toMap()).toList(),
      };

  /// Aceita o padrão antigo (ABC1234) e o Mercosul (ABC1D23), com ou sem
  /// hífen, e guarda a placa em maiúsculas.
  static String _validarPlaca(String placa) {
    final texto = placa.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
    if (texto.length != tamanhoPlaca ||
        !RegExp(r'^[A-Z]{3}\d[A-Z\d]\d{2}$').hasMatch(texto)) {
      throw ArgumentError('Placa inválida: $placa');
    }
    return texto;
  }

  static String _validarObrigatorio(String valor, String campo) {
    final texto = valor.trim();
    if (texto.isEmpty) throw ArgumentError('O campo $campo é obrigatório.');
    return texto;
  }

  @override
  String toString() => 'Veiculo(id: $id, ${identificacao()}, '
      'responsavel: ${responsavel.nome}, atendimentos: ${_atendimentos.length})';
}
