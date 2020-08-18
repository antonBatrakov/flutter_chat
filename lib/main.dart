import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/routes.dart';

import 'auth/auth_screen.dart';
import 'chat_list/main_screen.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: RouteNames.authScreen,
      routes: {
        RouteNames.authScreen: (context) => AuthPage(),
        RouteNames.mainScreen: (context) => MainPage(),
      },
    );
  }
}
