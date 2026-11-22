import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

class FirebaseService {
  FirebaseService(String uid)
    : _ref = FirebaseDatabase.instance.ref('tarefas').child(uid);

  final DatabaseReference _ref;

  Stream<List<Tarefa>> acompanhar() => _ref.onValue.map((event) {
    return event.snapshot.children
        .map((item) => Tarefa.fromJson(item.key!, item.value as Map))
        .toList()
      ..sort((a, b) => a.vencimento.compareTo(b.vencimento));
  });

  Future<void> salvar(Tarefa tarefa) {
    final destino = tarefa.id.isEmpty ? _ref.push() : _ref.child(tarefa.id);
    return destino.set(tarefa.toJson());
  }

  Future<void> excluir(Tarefa tarefa) => _ref.child(tarefa.id).remove();

  Future<void> alternar(Tarefa tarefa) =>
      _ref.child(tarefa.id).update({'concluida': !tarefa.concluida});
}
