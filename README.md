# Minhas Tarefas

Aplicativo Android da P2 de Programação Mobile. Inclui cadastro e login por e-mail, painel de totais, organização de tarefas pessoais e tema claro ou escuro.

## Executar no VS Code

1. Instale o Flutter, as extensões Flutter e Dart do VS Code e o Android SDK.
2. Abra esta pasta no VS Code. Se o SDK estiver em outro caminho, atualize a configuração local `dart.flutterSdkPath`.
3. Inicie um emulador Android ou conecte um aparelho com depuração USB.
4. Execute `flutter pub get`. Selecione o dispositivo Android e pressione **F5**, ou execute `flutter run`.

## Configurar o Firebase

O Android usa `android/app/google-services.json`, associado ao pacote `br.com.zanetti.gerenciador_tarefas`. Para usar outro projeto, registre esse pacote no Firebase e substitua o arquivo. Ative **E-mail/senha** em Authentication e crie uma instância do Realtime Database antes de baixar a configuração.

As tarefas ficam em `tarefas/{uid}/{id}`. Antes de executar com outro projeto, publique `database.rules.json` nesse projeto. As regras permitem leitura e escrita apenas ao usuário dono do UID e validam os campos.

```sh
firebase deploy --only database --project ID_DO_PROJETO
```

## Demonstração

1. Cadastre uma conta de demonstração, saia pelo menu lateral e faça login.
2. Cadastre duas tarefas com prioridades diferentes. Abra **Minhas tarefas** e confira a lista.
3. Abra uma tarefa, edite os campos e alterne a situação pela caixa da lista. Exclua a outra tarefa.
4. Abra **Configurações**, ative o tema escuro e reabra o aplicativo para conferir o tema e a sessão.
5. No console Firebase, confira a tarefa restante no Realtime Database, dentro do UID usado na demonstração.

## Capturas do emulador

- [Login](capturas/01-login.png) e [cadastro](capturas/02-cadastro.png)
- [Painel](capturas/03-painel.png) e [lista de tarefas](capturas/04-lista.png)
- [Detalhes](capturas/05-detalhes.png) e [edição](capturas/06-edicao.png)
- [Tema escuro após reabrir o aplicativo](capturas/07-tema-escuro.png)

## Verificação local

```sh
flutter analyze
flutter test
flutter build apk --debug
```
