import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/chat_list/chat_list_screen.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Alignment _alignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(onChange: (bool isVisible) {
      setState(() {
        _alignment = isVisible ? Alignment.topCenter : Alignment.center;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Container(
      color: Colors.blue[50],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          child: AnimatedContainer(
            curve: Curves.easeOut,
            alignment: _alignment,
            duration: Duration(milliseconds: 150),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlutterLogo(
                        textColor: Colors.black,
                        style: FlutterLogoStyle.horizontal,
                        size: 110,
                      ),
                      Text(
                        AuthScreenStrings.authScreenTitle,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 26),
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: TextField(
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              labelText: AuthScreenStrings.authScreenEmail,
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              labelText: AuthScreenStrings.authScreenPassword,
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: MaterialButton(
                          color: Colors.blue,
                          minWidth: double.infinity,
                          child: Text(
                            AuthScreenStrings.authScreenSignIn,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatListPage(),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
