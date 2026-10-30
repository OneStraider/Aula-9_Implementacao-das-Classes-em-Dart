import 'package:oficina/oficina.dart';
import 'package:test/test.dart';

void main() {
  late Responsavel maria;
  late Veiculo gol;
  late TipoTrabalho oleo;
  late TipoTrabalho freio;
  late Atendimento atendimento;

  setUp(() {
    maria = Responsavel(
        id: 1, cpf: '123.456.789-09', nome: 'Maria', telefone: '4899990000');
    gol = Veiculo(
      id: 10,
      placa: 'abc-1234',
      marca: 'VW',
      modelo: 'Gol',
      ano: 2020,
      cor: 'Prata',
      responsavel: maria,
    );
    maria.adicionarVeiculo(gol);
    oleo = TipoTrabalho(id: 1, descricao: 'Óleo', valorPadrao: 100);
    freio = TipoTrabalho(id: 2, descricao: 'Freio', valorPadrao: 50);
    atendimento =
        Atendimento(id: 100, veiculo: gol, problemaRelatado: 'Barulho');
    gol.registrarAtendimento(atendimento);
  });

  group('Atendimento', () {
    test('total é calculado a partir dos itens', () {
      atendimento
        ..adicionarTrabalho(oleo)
        ..adicionarTrabalho(freio);
      expect(atendimento.calcularValorTotal(), 150);
    });

    test('não conclui sem trabalhos', () {
      atendimento.alterarSituacao(Situacao.emAndamento);
      expect(() => atendimento.alterarSituacao(Situacao.concluido),
          throwsStateError);
      expect(() => atendimento.copyWith(situacao: Situacao.concluido),
          throwsStateError);
    });

    test('só aceita transições válidas de situação', () {
      expect(() => atendimento.alterarSituacao(Situacao.concluido),
          throwsStateError);
      atendimento
        ..adicionarTrabalho(oleo)
        ..alterarSituacao(Situacao.emAndamento)
        ..alterarSituacao(Situacao.aguardandoPeca)
        ..alterarSituacao(Situacao.emAndamento)
        ..alterarSituacao(Situacao.concluido);
      expect(atendimento.estaConcluido(), isTrue);
      expect(atendimento.dataConclusao, isNotNull);
      expect(() => atendimento.alterarSituacao(Situacao.emAndamento),
          throwsStateError);
    });

    test('concluído não aceita alteração de trabalhos', () {
      atendimento
        ..adicionarTrabalho(oleo)
        ..alterarSituacao(Situacao.emAndamento)
        ..alterarSituacao(Situacao.concluido);
      expect(() => atendimento.adicionarTrabalho(freio), throwsStateError);
      expect(() => atendimento.removerTrabalho(oleo), throwsStateError);
    });

    test('não repete trabalho e não remove trabalho ausente', () {
      atendimento.adicionarTrabalho(oleo);
      expect(() => atendimento.adicionarTrabalho(oleo), throwsStateError);
      expect(() => atendimento.removerTrabalho(freio), throwsStateError);
      atendimento.removerTrabalho(oleo);
      expect(atendimento.itens, isEmpty);
    });

    test('reajuste do tipo não altera o valor já cobrado', () {
      atendimento.adicionarTrabalho(oleo);
      oleo.reajustarValor(180);
      expect(oleo.valorPadrao, 180);
      expect(atendimento.calcularValorTotal(), 100);
    });

    test('copyWith preserva veículo, placa e data de entrada', () {
      final copia = atendimento.copyWith(problemaRelatado: 'Outro');
      expect(copia.problemaRelatado, 'Outro');
      expect(copia.dataEntrada, atendimento.dataEntrada);
      expect(copia.veiculo.placa, 'ABC1234');
    });

    test('lista de itens exposta é somente leitura', () {
      expect(() => atendimento.itens.add(ItemAtendimento(tipo: oleo)),
          throwsUnsupportedError);
    });

    test('fromMap rejeita mapa de outro veículo', () {
      final outro = gol.copyWith(cor: 'Azul');
      final mapa = atendimento.toMap()..['id_veiculo'] = 99;
      expect(() => Atendimento.fromMap(mapa, outro), throwsArgumentError);
    });
  });

  group('Veiculo e Responsavel', () {
    test('placa é normalizada e fica igual na cópia', () {
      expect(gol.placa, 'ABC1234');
      expect(gol.copyWith(cor: 'Azul').placa, 'ABC1234');
    });

    test('placa e CPF inválidos são rejeitados', () {
      expect(
        () => Veiculo(
            id: 2,
            placa: '12345',
            marca: 'X',
            modelo: 'Y',
            ano: 2020,
            cor: 'Z',
            responsavel: maria),
        throwsArgumentError,
      );
      expect(() => Responsavel(id: 2, cpf: '123', nome: 'A', telefone: '1'),
          throwsArgumentError);
    });

    test('não adiciona veículo de outro responsável', () {
      final joao = Responsavel(
          id: 2, cpf: '98765432100', nome: 'João', telefone: '4888880000');
      expect(() => joao.adicionarVeiculo(gol), throwsArgumentError);
    });
  });

  test('toMap/fromMap reconstroem o responsável com todos os relacionamentos',
      () {
    atendimento
      ..adicionarTrabalho(oleo, observacao: 'Sintético')
      ..alterarSituacao(Situacao.emAndamento)
      ..alterarSituacao(Situacao.concluido);

    final reconstruido = Responsavel.fromMap(maria.toMap());
    expect(reconstruido.toMap(), maria.toMap());

    final atendimentoReconstruido =
        reconstruido.listarVeiculos().single.historicoAtendimentos().single;
    expect(atendimentoReconstruido.estaConcluido(), isTrue);
    expect(atendimentoReconstruido.itens.single.observacao, 'Sintético');
    expect(identical(atendimentoReconstruido.veiculo.responsavel, reconstruido),
        isTrue);
  });
}
