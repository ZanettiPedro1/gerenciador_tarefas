import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  bool cadastro = false;
  bool ocupado = false;
  String? erro;

  Future<void> enviar() async {
    if (ocupado || !form.currentState!.validate()) return;
    final nomeInformado = nome.text.trim();
    final emailInformado = email.text.trim();
    final senhaInformada = senha.text;
    setState(() {
      ocupado = true;
      erro = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (cadastro) {
        final credencial = await auth.createUserWithEmailAndPassword(
          email: emailInformado,
          password: senhaInformada,
        );
        await credencial.user!.updateDisplayName(nomeInformado);
      } else {
        await auth.signInWithEmailAndPassword(
          email: emailInformado,
          password: senhaInformada,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => erro = switch (e.code) {
            'invalid-email' => 'Informe um e-mail válido.',
            'email-already-in-use' => 'Já existe uma conta com esse e-mail.',
            'weak-password' => 'Escolha uma senha mais forte.',
            'invalid-credential' ||
            'wrong-password' ||
            'user-not-found' => 'E-mail ou senha incorretos.',
            'network-request-failed' => 'Confira sua conexão com a internet.',
            'too-many-requests' =>
              'Muitas tentativas. Aguarde e tente novamente.',
            _ => 'Não foi possível autenticar. Tente novamente.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 54,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Minhas Tarefas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  if (cadastro) ...[
                    TextFormField(
                      controller: nome,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (valor) =>
                          valor!.trim().isEmpty ? 'Informe seu nome.' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (valor) =>
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(valor!.trim())
                        ? null
                        : 'Informe um e-mail válido.',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: senha,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: (valor) => valor!.isEmpty
                        ? 'Informe a senha.'
                        : cadastro && valor.length < 6
                        ? 'Use pelo menos seis caracteres.'
                        : null,
                    onFieldSubmitted: (_) => enviar(),
                  ),
                  if (erro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: ocupado ? null : enviar,
                    child: Text(
                      ocupado
                          ? 'Aguarde…'
                          : cadastro
                          ? 'Criar conta'
                          : 'Entrar',
                    ),
                  ),
                  TextButton(
                    onPressed: ocupado
                        ? null
                        : () => setState(() {
                            cadastro = !cadastro;
                            erro = null;
                          }),
                    child: Text(
                      cadastro ? 'Já tenho conta' : 'Criar uma conta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
