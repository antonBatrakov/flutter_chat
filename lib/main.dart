import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/api/info_api.dart';
import 'package:flutter_chat/chat_list/models/lang_model.dart';
import 'package:flutter_chat/repository/chat_repository.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:flutter_chat/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'auth/auth_screen.dart';
import 'chat/chat_screen.dart';
import 'chat_list/main_screen.dart';
import 'generated/l10n.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(S.of(context).authScreenSignInError);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ChatApp();
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        Provider<InfoService>(
          create: (_) => InfoService.create(),
          dispose: (_, value) => value.client.dispose(),
        ),
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        Provider<ChatRepository>(
          create: (_) => ChatRepository(),
        ),
        ChangeNotifierProvider<LangChangeNotifier>(
          create: (_) => LangChangeNotifier(),
        )
      ],
      child: Consumer<LangChangeNotifier>(
        builder: (_, value, ___) => MaterialApp(
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: [
            const Locale('en', "US"),
            const Locale('ru', "RU"),
          ],
          locale: value.chosenLocale,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: RouteNames.authScreen,
          routes: {
            RouteNames.authScreen: (context) => AuthPage(),
            RouteNames.mainScreen: (context) => MainPage(),
            RouteNames.chatScreen: (context) => ChatPage(),
          },
        ),
      ),
    );
  }
}
