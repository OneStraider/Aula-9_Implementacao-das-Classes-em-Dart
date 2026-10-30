import 'veiculo.dart';

/// Pessoa responsável por um ou mais veículos. O CPF identifica o
/// responsável e não muda; nome, telefone e e-mail podem ser atualizados.
class Responsavel {
  final int id;
  final String cpf;
  String _nome;
  String _telefone;
  String? _email;
  final List<Veiculo> _veiculos = [];

  Responsavel({
    required this.id,
    required String cpf,
    required String nome,
    required String telefone,
    String? email,
  })  : cpf = _validarCpf(cpf),
        _nome = _validarObrigatorio(nome, 'nome'),
        _telefone = _validarObrigatorio(telefone, 'telefone'),
        _email = _validarEmail(email);

  /// Reconstrói o responsável junto com seus veículos (e os atendimentos de
  /// cada veículo), quando presentes no mapa.
  factory Responsavel.fromMap(Map<String, dynamic> map) {
    final responsavel = Responsavel(
      id: map['id_responsavel'] as int,
      cpf: map['cpf'] as String,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String?,
    );
    for (final veiculo in (map['veiculos'] as List?) ?? const []) {
      responsavel.adicionarVeiculo(Veiculo.fromMap(
          Map<String, dynamic>.from(veiculo as Map), responsavel));
    }
    return responsavel;
  }

  String get nome => _nome;
  set nome(String valor) => _nome = _validarObrigatorio(valor, 'nome');

  String get telefone => _telefone;
  set telefone(String valor) =>
      _telefone = _validarObrigatorio(valor, 'telefone');

  String? get email => _email;
  set email(String? valor) => _email = _validarEmail(valor);

  void adicionarVeiculo(Veiculo veiculo) {
    if (veiculo.responsavel.id != id) {
      throw ArgumentError(
          'O veículo ${veiculo.placa} pertence a outro responsável.');
    }
    if (_veiculos.any((v) => v.placa == veiculo.placa)) {
      throw StateError('O veículo ${veiculo.placa} já está cadastrado.');
    }
    _veiculos.add(veiculo);
  }

  List<Veiculo> listarVeiculos() => List.unmodifiable(_veiculos);

  String contato() => _email == null ? _telefone : '$_telefone / $_email';

  /// Id e CPF identificam o responsável e não são trocados na cópia; a cópia
  /// mantém os mesmos veículos.
  Responsavel copyWith({String? nome, String? telefone, String? email}) =>
      Responsavel(
        id: id,
        cpf: cpf,
        nome: nome ?? _nome,
        telefone: telefone ?? _telefone,
        email: email ?? _email,
      ).._veiculos.addAll(_veiculos);

  /// Os veículos vão aninhados; cada um guarda só o id do responsável, o que
  /// evita referência circular.
  Map<String, dynamic> toMap() => {
        'id_responsavel': id,
        'cpf': cpf,
        'nome': _nome,
        'telefone': _telefone,
        'email': _email,
        'veiculos': _veiculos.map((v) => v.toMap()).toList(),
      };

  static String _validarCpf(String cpf) {
    final digitos = cpf.replaceAll(RegExp(r'[.\-\s]'), '');
    if (!RegExp(r'^\d{11}$').hasMatch(digitos)) {
      throw ArgumentError('CPF inválido: $cpf');
    }
    return digitos;
  }

  static String _validarObrigatorio(String valor, String campo) {
    final texto = valor.trim();
    if (texto.isEmpty) throw ArgumentError('O campo $campo é obrigatório.');
    return texto;
  }

  static String? _validarEmail(String? email) {
    final texto = email?.trim();
    if (texto == null || texto.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
      throw ArgumentError('E-mail inválido: $email');
    }
    return texto;
  }

  @override
  String toString() => 'Responsavel(id: $id, cpf: $cpf, nome: $_nome, '
      'contato: ${contato()}, veiculos: ${_veiculos.length})';
}
