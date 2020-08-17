import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:flutter_chat/routes.dart';

import 'auth/auth_screen.dart';
import 'chat_list/main_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text(AuthScreenStrings.authScreenSignInError);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return ChatApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
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
