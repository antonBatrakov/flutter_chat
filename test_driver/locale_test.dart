import 'dart:developer';

import 'package:flutter_chat/auth/auth_widget_keys.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/settings_key_value.dart';
import 'package:flutter_chat/chat_list/main_screen_keys.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

//  Testable user
//  login: test@test.ru
//  password: 123456789
void main() {
  group(
    'App lang test',
    () {
      final emailEditTextFinder = find.byValueKey(AuthKeys.emailTextFieldKey);
      final passwordEditTextFinder =
          find.byValueKey(AuthKeys.passwordTextFieldKey);
      final loginButtonFinder = find.byValueKey(AuthKeys.loginButtonKey);
      final mainTabBarFinder = find.byValueKey(MainScreenKeys.mainTabBar);
      final settingsTabFinder = find.byValueKey(MainScreenKeys.settingsTab);
      final langTileFinder = find.byValueKey(SettingsKeys.langTile);
      final langTileTrailingFinder = find.byValueKey(SettingsKeys.langTileTrailing);
      final langListFinder = find.byValueKey(SettingsKeys.langList);

      FlutterDriver driver;
      setUpAll(() async {
        driver = await FlutterDriver.connect();
      });

      tearDownAll(() async {
        if (driver != null) {
          driver.close();
        }
      });

      test('System Locale is selected', () async {
        await driver.tap(emailEditTextFinder,
            timeout: Duration(milliseconds: 500));
        await driver.enterText("test@test.ru");

        await driver.tap(passwordEditTextFinder,
            timeout: Duration(milliseconds: 500));
        await driver.enterText("123456789");

        await driver.tap(loginButtonFinder, timeout: Duration(seconds: 1));
        await driver.waitFor(mainTabBarFinder);
        await driver.tap(settingsTabFinder, timeout: Duration(seconds: 1));

        await driver.tap(langTileFinder, timeout: Duration(seconds: 1));
        await driver.waitFor(langListFinder);
        await driver.tap(find.text('Русский'));
        expect(await driver.getText(langTileTrailingFinder), 'Русский');

        await driver.tap(langTileFinder, timeout: Duration(seconds: 1));
        await driver.waitFor(langListFinder);
        await driver.tap(find.text('English'));
        expect(await driver.getText(langTileTrailingFinder), 'English');
      });
    },
  );
}
