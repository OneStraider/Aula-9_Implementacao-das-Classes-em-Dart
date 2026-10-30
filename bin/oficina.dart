import 'package:oficina/oficina.dart';

void main() {
  final maria = Responsavel(
    id: 1,
    cpf: '123.456.789-09',
    nome: 'Maria Silva',
    telefone: '(48) 99999-0000',
    email: 'maria@email.com',
  );
  final gol = Veiculo(
    id: 1,
    placa: 'abc-1d23',
    marca: 'Volkswagen',
    modelo: 'Gol',
    ano: 2020,
    cor: 'Prata',
    responsavel: maria,
  );
  maria.adicionarVeiculo(gol);

  final oleo =
      TipoTrabalho(id: 1, descricao: 'Troca de óleo', valorPadrao: 150);
  final freio =
      TipoTrabalho(id: 2, descricao: 'Revisão de freios', valorPadrao: 320);

  final atendimento =
      Atendimento(id: 1, veiculo: gol, problemaRelatado: 'Barulho ao frear');
  gol.registrarAtendimento(atendimento);
  atendimento.alterarSituacao(Situacao.emAndamento);

  try {
    atendimento.alterarSituacao(Situacao.concluido);
  } on StateError catch (e) {
    print('Regra de negócio: ${e.message}\n');
  }

  atendimento
    ..adicionarTrabalho(oleo)
    ..adicionarTrabalho(freio, observacao: 'Pastilhas dianteiras');

  oleo.reajustarValor(180); // não altera o valor já cobrado no atendimento
  atendimento.alterarSituacao(Situacao.concluido);
  print(atendimento.resumo());

  final reconstruido = Responsavel.fromMap(maria.toMap());
  print('\nReconstruído a partir do Map: $reconstruido');
  print(reconstruido.listarVeiculos().first.historicoAtendimentos().first);
}
