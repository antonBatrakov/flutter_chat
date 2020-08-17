import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/auth/password_field.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:flutter_chat/resources/assets.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:flutter_chat/routes.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  final UserRepository _userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SignInModel(_userRepository)),
          ChangeNotifierProvider(create: (_) => PasswordModel()),
        ],
        builder: (providerContext, _) => Consumer<SignInModel>(
          builder: (consumerContext, value, child) {
            switch (value.result) {
              case SignInResult.success:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(
                      context, RouteNames.mainScreen);
                });
                return child;
              case SignInResult.failed:
                Fluttertoast.showToast(
                  msg: AuthScreenStrings.authScreenSignInError,
                  backgroundColor: Colors.grey,
                );
                return child;
              case SignInResult.inProgress:
                return Stack(children: <Widget>[
                  child,
                  Container(
                      color: Colors.white60,
                      child: Center(child: const CircularProgressIndicator())),
                ]);
              case SignInResult.none:
                return child;
              default:
                return child;
            }
          },
          child: KeyboardVisibilityProvider(child: AuthFields()),
        ),
      ),
    );
  }
}

class AuthFields extends StatelessWidget {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                alignment: KeyboardVisibilityProvider.isKeyboardVisible(context)
                    ? Alignment.topCenter
                    : Alignment.center,
                duration: Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _authScreenHeader(),
                    _emailTextField(context, _emailTextFieldController),
                    _passwordTextField(_passwordTextFieldController),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                      child: _signInButton(
                        context,
                        _emailTextFieldController,
                        _passwordTextFieldController,
                      ),
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
                  _googleSignInButton(context),
                ],
              ),
            ),
          ],
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

Widget _passwordTextField(TextEditingController controller) =>
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Consumer<PasswordModel>(
        builder: (ctx, value, child) =>
            TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              obscureText: value.isObscure,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                      value.isObscure ? Icons.lock_outline : Icons.lock_open),
                  onPressed:() => value.toggleObscure(),
                ),
                alignLabelWithHint: true,
                labelText: AuthScreenStrings.authScreenPassword,
                border: UnderlineInputBorder(),
              ),
            ),
      ),
    );

Widget _emailTextField(BuildContext context,
    TextEditingController controller) =>
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: TextField(
        controller: controller,
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

Widget _signInButton(BuildContext context,
    TextEditingController emailTextFieldController,
    TextEditingController passwordTextFieldController) =>
    MaterialButton(
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
          Provider.of<SignInModel>(
            context,
            listen: false,
          ).signInWithCredentials(
              emailTextFieldController.text, passwordTextFieldController.text),
    );

Widget _googleSignInButton(BuildContext context) => OutlineButton(
      splashColor: Colors.grey,
      onPressed: () => Provider.of<SignInModel>(
        context,
        listen: false,
      ).signInWithGoogle(),
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
