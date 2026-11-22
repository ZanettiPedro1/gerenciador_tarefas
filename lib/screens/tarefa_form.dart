import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';

class TarefaForm extends StatefulWidget {
  const TarefaForm({super.key, required this.service, this.tarefa});
  final FirebaseService service;
  final Tarefa? tarefa;

  @override
  State<TarefaForm> createState() => _TarefaFormState();
}

class _TarefaFormState extends State<TarefaForm> {
  final form = GlobalKey<FormState>();
  late final titulo = TextEditingController(text: widget.tarefa?.titulo);
  late final descricao = TextEditingController(text: widget.tarefa?.descricao);
  late DateTime vencimento =
      widget.tarefa?.vencimento ?? DateUtils.dateOnly(DateTime.now());
  late Prioridade prioridade = widget.tarefa?.prioridade ?? Prioridade.media;
  late bool concluida = widget.tarefa?.concluida ?? false;
  bool salvando = false;

  Future<void> escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: vencimento,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (escolhida != null && mounted) setState(() => vencimento = escolhida);
  }

  Future<void> salvar() async {
    if (salvando || !form.currentState!.validate()) return;
    setState(() => salvando = true);
    try {
      await widget.service.salvar(
        Tarefa(
          id: widget.tarefa?.id ?? '',
          titulo: titulo.text.trim(),
          descricao: descricao.text.trim(),
          vencimento: vencimento,
          prioridade: prioridade,
          concluida: concluida,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao salvar a tarefa.')),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: titulo,
            decoration: const InputDecoration(labelText: 'Título'),
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            validator: (valor) =>
                valor!.trim().isEmpty ? 'Informe o título.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descricao,
            decoration: const InputDecoration(labelText: 'Descrição'),
            minLines: 3,
            maxLines: 5,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: salvando ? null : escolherData,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              'Vencimento: ${MaterialLocalizations.of(context).formatCompactDate(vencimento)}',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Prioridade>(
            initialValue: prioridade,
            decoration: const InputDecoration(labelText: 'Prioridade'),
            items: Prioridade.values
                .map(
                  (valor) =>
                      DropdownMenuItem(value: valor, child: Text(valor.label)),
                )
                .toList(),
            onChanged: salvando
                ? null
                : (valor) => setState(() => prioridade = valor!),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: concluida,
            title: Text(concluida ? 'Concluída' : 'Pendente'),
            onChanged: salvando
                ? null
                : (valor) => setState(() => concluida = valor),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: salvando ? null : salvar,
            child: Text(salvando ? 'Salvando…' : 'Salvar tarefa'),
          ),
        ],
      ),
    ),
  );
}
