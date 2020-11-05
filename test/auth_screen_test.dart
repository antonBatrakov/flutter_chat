import 'package:flutter/material.dart';
import 'package:flutter_chat/auth/auth_screen.dart';
import 'package:flutter_chat/auth/auth_widget_keys.dart';
import 'package:flutter_chat/auth/password_field.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class AuthModelMock extends Mock implements AuthModel {}
class PasswordModelMock extends Mock implements PasswordModel {}
class UserRepositoryMock extends Mock implements UserRepository {}

void main() {
  group('Auth screen', () {
    AuthModelMock authModel;
    PasswordModelMock passwordModel;
    UserRepositoryMock userRepository;

    Widget _materialWrap(Widget child) {
      return MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: child,
        ),
      );
    }

    setUpAll(() {
      authModel = AuthModelMock();
      passwordModel = PasswordModelMock();
      userRepository = UserRepositoryMock();
      KeyboardVisibility.setVisibilityForTesting(true);
    });

    testWidgets(
        'WHEN login pressed THEN email and password data passed to model',
        (tester) async {
      // given
      when(passwordModel.hasListeners).thenAnswer((realInvocation) => false);
      when(passwordModel.isObscure).thenAnswer((realInvocation) => true);
      when(authModel.hasListeners).thenAnswer((realInvocation) => false);
      when(authModel.result).thenAnswer((realInvocation) => AuthResult.inProgress);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthModel>(
              create: (_) => authModel,
            ),
            ChangeNotifierProvider<PasswordModel>(
              create: (_) => passwordModel,
            ),
            Provider<UserRepository>(
              create: (_) => userRepository,
            ),
          ],
          builder: (_, child) => child,
          child: _materialWrap(KeyboardVisibilityProvider(child: AuthFields())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key(AuthKeys.emailTextFieldKey)), "qwe");
      await tester.enterText(find.byKey(Key(AuthKeys.passwordTextFieldKey)), "qwe");

      //when
      await tester.tap(find.byKey(Key(AuthKeys.loginButtonKey)));

      //then
      verify(authModel.signInWithCredentials("qwe", "qwe")).called(1);
    });
  });
}
