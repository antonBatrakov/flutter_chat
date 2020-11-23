import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:provider/provider.dart';

import 'auth_widget_keys.dart';

class SignInButton extends StatefulWidget {
  SignInButton(this._emailTextFieldController, this._passwordTextFieldController);
  final TextEditingController _emailTextFieldController;
  final TextEditingController _passwordTextFieldController;

  @override
  _SignInButtonState createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  Color targetColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: ColorTween(begin: Colors.blue, end: targetColor),
      curve: Curves.ease,
      onEnd: () {
        setState(() {
          targetColor = targetColor == Colors.black ? Colors.blue : Colors.black;
        });
      },
      builder: (ctx, color, _) => MaterialButton(
          key: Key(AuthKeys.loginButtonKey),
          padding: EdgeInsets.all(15),
          color: color,
          minWidth: double.infinity,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Text(
            S.of(context).authScreenSignIn,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Provider.of<AuthModel>(
              context,
              listen: false,
            ).signInWithCredentials(widget._emailTextFieldController.text,
                widget._passwordTextFieldController.text);
          }),
    );
  }
}