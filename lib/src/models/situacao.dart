/// Situações de um atendimento e as transições permitidas entre elas.
enum Situacao {
  aberto('Aberto'),
  emAndamento('Em andamento'),
  aguardandoPeca('Aguardando peça'),
  concluido('Concluído');

  final String rotulo;

  const Situacao(this.rotulo);

  /// Situações para as quais é possível ir a partir desta.
  Set<Situacao> get proximas => switch (this) {
        Situacao.aberto => const {Situacao.emAndamento},
        Situacao.emAndamento => const {
            Situacao.aguardandoPeca,
            Situacao.concluido,
          },
        Situacao.aguardandoPeca => const {Situacao.emAndamento},
        Situacao.concluido => const {},
      };

  bool podeMudarPara(Situacao nova) => proximas.contains(nova);
}
