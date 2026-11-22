import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/models/tarefa.dart';

void main() {
  test('preserva a data civil e os campos da tarefa ao persistir', () {
    final tarefa = Tarefa(
      id: 'tarefa-1',
      titulo: 'Revisar Flutter',
      descricao: 'Revisar o capítulo sobre navegação.',
      vencimento: DateTime(2026, 11, 22),
      prioridade: Prioridade.alta,
      concluida: true,
    );

    final json = tarefa.toJson();
    expect(json['vencimento'], '2026-11-22');
    final recuperada = Tarefa.fromJson(tarefa.id, json);
    expect(recuperada.id, tarefa.id);
    expect(recuperada.vencimento, tarefa.vencimento);
    expect(recuperada.toJson(), json);
  });
}
