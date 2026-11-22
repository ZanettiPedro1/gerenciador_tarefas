import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/firebase_service.dart';
import 'tarefa_form.dart';

enum Secao {
  inicio('Início', Icons.home_outlined),
  tarefas('Minhas tarefas', Icons.checklist),
  configuracoes('Configurações', Icons.settings_outlined),
  sobre('Sobre o aplicativo', Icons.info_outline);

  const Secao(this.label, this.icone);
  final String label;
  final IconData icone;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.usuario,
    required this.escuro,
    required this.alterarTema,
  });
  final Usuario usuario;
  final bool escuro;
  final Future<void> Function(bool) alterarTema;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final service = FirebaseService(widget.usuario.uid);
  late final tarefas = service.acompanhar();
  Secao secao = Secao.inicio;

  Future<void> executar(Future<void> Function() operacao, String erro) async {
    try {
      await operacao();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(erro)));
      }
    }
  }

  Future<void> abrirForm([Tarefa? tarefa]) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => TarefaForm(service: service, tarefa: tarefa),
    ),
  );

  String data(Tarefa tarefa) =>
      MaterialLocalizations.of(context).formatCompactDate(tarefa.vencimento);

  String situacao(Tarefa tarefa) => tarefa.concluida ? 'Concluída' : 'Pendente';

  Future<void> excluir(Tarefa tarefa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text(tarefa.titulo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado == true && mounted) {
      await executar(
        () => service.excluir(tarefa),
        'Falha ao excluir a tarefa.',
      );
    }
  }

  Future<void> detalhes(Tarefa tarefa) async {
    final acao = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(tarefa.titulo),
        content: SingleChildScrollView(
          child: Text(
            'Vencimento: ${data(tarefa)}\nPrioridade: ${tarefa.prioridade.label}\nSituação: ${situacao(tarefa)}'
            '${tarefa.descricao.isEmpty ? '' : '\n\n${tarefa.descricao}'}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, 'excluir'),
            child: const Text('Excluir'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, 'editar'),
            child: const Text('Editar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (acao == 'editar') await abrirForm(tarefa);
    if (acao == 'excluir') await excluir(tarefa);
  }

  Widget painel(List<Tarefa> itens) {
    final concluidas = itens.where((tarefa) => tarefa.concluida).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Olá, ${widget.usuario.nome}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        for (final (icone, label, total) in [
          (Icons.checklist, 'Cadastradas', itens.length),
          (Icons.pending_actions, 'Pendentes', itens.length - concluidas),
          (Icons.task_alt, 'Concluídas', concluidas),
        ])
          Card(
            child: ListTile(
              leading: Icon(icone),
              title: Text(label),
              trailing: Text('$total'),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() => secao = Secao.tarefas),
          child: const Text('Ver minhas tarefas'),
        ),
      ],
    );
  }

  Widget lista(List<Tarefa> itens) {
    if (itens.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa cadastrada.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: itens.length,
      itemBuilder: (context, index) {
        final tarefa = itens[index];
        final icone = switch (tarefa.prioridade) {
          Prioridade.baixa => Icons.keyboard_arrow_down,
          Prioridade.media => Icons.remove,
          Prioridade.alta => Icons.priority_high,
        };
        return Card(
          child: ListTile(
            leading: Icon(icone, semanticLabel: tarefa.prioridade.label),
            title: Text(tarefa.titulo),
            subtitle: Text(
              '${data(tarefa)} · ${tarefa.prioridade.label}\n${situacao(tarefa)}',
            ),
            isThreeLine: true,
            onTap: () => detalhes(tarefa),
            trailing: Checkbox(
              semanticLabel:
                  'Marcar ${tarefa.titulo} como ${tarefa.concluida ? 'pendente' : 'concluída'}',
              value: tarefa.concluida,
              onChanged: (_) => executar(
                () => service.alternar(tarefa),
                'Falha ao atualizar a situação.',
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mostraTarefas = secao == Secao.inicio || secao == Secao.tarefas;
    return Scaffold(
      appBar: AppBar(title: Text(secao.label)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.usuario.nome),
              accountEmail: Text(widget.usuario.email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person_outline),
              ),
            ),
            for (final item in Secao.values)
              ListTile(
                selected: secao == item,
                leading: Icon(item.icone),
                title: Text(item.label),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => secao = item);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                executar(
                  FirebaseAuth.instance.signOut,
                  'Falha ao encerrar a sessão.',
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Tarefa>>(
        stream: tarefas,
        builder: (context, snapshot) => switch (secao) {
          Secao.configuracoes => ListView(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Tema escuro'),
                value: widget.escuro,
                onChanged: (valor) => executar(
                  () => widget.alterarTema(valor),
                  'Falha ao salvar o tema.',
                ),
              ),
            ],
          ),
          Secao.sobre => const ListTile(
            leading: Icon(Icons.task_alt),
            title: Text('Minhas Tarefas'),
            subtitle: Text(
              'Aplicativo de gerenciamento de tarefas pessoais.\nP2 de Programação Mobile.',
            ),
          ),
          _ when snapshot.hasError => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Falha ao carregar as tarefas. Confira a conexão e as regras do Firebase.',
              ),
            ),
          ),
          _ when !snapshot.hasData => const Center(
            child: CircularProgressIndicator(),
          ),
          Secao.inicio => painel(snapshot.data!),
          Secao.tarefas => lista(snapshot.data!),
        },
      ),
      floatingActionButton: mostraTarefas
          ? FloatingActionButton.extended(
              onPressed: () => abrirForm(),
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
            )
          : null,
    );
  }
}
