import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/resources/assets.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:flutter_chat/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: AnimatedContainer(
                  curve: Curves.easeOut,
                  alignment: _alignment,
                  duration: Duration(milliseconds: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _authScreenHeader(),
                      _emailTextField(context),
                      _passwordTextField(context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                        child: _signInButton(context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    _googleSignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _authScreenHeader() => Row(
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
              color: Colors.black, fontWeight: FontWeight.w400, fontSize: 26),
        )
      ],
    );

Widget _passwordTextField(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: TextField(
        textInputAction: TextInputAction.done,
        obscureText: true,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: AuthScreenStrings.authScreenPassword,
          border: UnderlineInputBorder(),
        ),
      ),
    );

Widget _emailTextField(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: TextField(
        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: AuthScreenStrings.authScreenEmail,
          border: UnderlineInputBorder(),
        ),
      ),
    );

Widget _signInButton(BuildContext context) => MaterialButton(
      padding: EdgeInsets.all(15),
      color: Colors.blue,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Text(
        AuthScreenStrings.authScreenSignIn,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () =>
          Navigator.pushReplacementNamed(context, RouteNames.mainScreen),
    );

Widget _googleSignInButton() => OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        Fluttertoast.showToast(
          msg: DebugStrings.debugInDevelopment,
          backgroundColor: Colors.grey,
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(AuthImg.googleSignInLogo), height: 25.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AuthScreenStrings.authScreenSignInWithGoogle,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
