enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  const Prioridade(this.label);
  final String label;
}

class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.vencimento,
    required this.prioridade,
    required this.concluida,
  });

  final String id;
  final String titulo;
  final String descricao;
  final DateTime vencimento;
  final Prioridade prioridade;
  final bool concluida;

  factory Tarefa.fromJson(String id, Map<Object?, Object?> json) => Tarefa(
    id: id,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String,
    vencimento: DateTime.parse(json['vencimento'] as String),
    prioridade: Prioridade.values.byName(json['prioridade'] as String),
    concluida: json['concluida'] as bool,
  );

  Map<String, Object> toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'vencimento': vencimento.toIso8601String().split('T').first,
    'prioridade': prioridade.name,
    'concluida': concluida,
  };
}
