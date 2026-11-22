import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/usuario.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferencesAsync();
  final escuro = await prefs.getBool('temaEscuro') ?? false;
  try {
    await Firebase.initializeApp();
    runApp(App(prefs: prefs, escuro: escuro));
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível iniciar o Firebase. Confira a configuração Android no README.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, required this.prefs, required this.escuro});
  final SharedPreferencesAsync prefs;
  final bool escuro;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late bool escuro = widget.escuro;
  final sessao = FirebaseAuth.instance.userChanges();

  ThemeData tema(Brightness brilho) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff28604d),
      brightness: brilho,
    ),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Minhas Tarefas',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: tema(Brightness.light),
    darkTheme: tema(Brightness.dark),
    themeMode: escuro ? ThemeMode.dark : ThemeMode.light,
    home: StreamBuilder<User?>(
      stream: sessao,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Falha ao verificar a sessão.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const AuthScreen();
        return HomeScreen(
          key: ValueKey(user.uid),
          usuario: Usuario(
            uid: user.uid,
            nome: user.displayName ?? 'Usuário',
            email: user.email ?? '',
          ),
          escuro: escuro,
          alterarTema: (valor) async {
            await widget.prefs.setBool('temaEscuro', valor);
            if (mounted) setState(() => escuro = valor);
          },
        );
      },
    ),
  );
}
