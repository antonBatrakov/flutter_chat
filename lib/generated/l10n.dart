// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Chat`
  String get authScreenTitle {
    return Intl.message(
      'Chat',
      name: 'authScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `email`
  String get authScreenEmail {
    return Intl.message(
      'email',
      name: 'authScreenEmail',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get authScreenPassword {
    return Intl.message(
      'password',
      name: 'authScreenPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get authScreenSignIn {
    return Intl.message(
      'Sign In',
      name: 'authScreenSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign In with Google`
  String get authScreenSignInWithGoogle {
    return Intl.message(
      'Sign In with Google',
      name: 'authScreenSignInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Sign In failed`
  String get authScreenSignInError {
    return Intl.message(
      'Sign In failed',
      name: 'authScreenSignInError',
      desc: '',
      args: [],
    );
  }

  /// `Chat List`
  String get chatScreenTitle {
    return Intl.message(
      'Chat List',
      name: 'chatScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `chats`
  String get chatScreenChats {
    return Intl.message(
      'chats',
      name: 'chatScreenChats',
      desc: '',
      args: [],
    );
  }

  /// `groups`
  String get chatScreenGroups {
    return Intl.message(
      'groups',
      name: 'chatScreenGroups',
      desc: '',
      args: [],
    );
  }

  /// `settings`
  String get chatScreenSettings {
    return Intl.message(
      'settings',
      name: 'chatScreenSettings',
      desc: '',
      args: [],
    );
  }

  /// `Choose language`
  String get settingsScreenChangeLangTitle {
    return Intl.message(
      'Choose language',
      name: 'settingsScreenChangeLangTitle',
      desc: '',
      args: [],
    );
  }

  /// `Fetching...`
  String get settingsScreenFetching {
    return Intl.message(
      'Fetching...',
      name: 'settingsScreenFetching',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get settingsScreenLogout {
    return Intl.message(
      'Log out',
      name: 'settingsScreenLogout',
      desc: '',
      args: [],
    );
  }

  /// `On no`
  String get closeDialogTitle {
    return Intl.message(
      'On no',
      name: 'closeDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to close the application?`
  String get closeDialogDetails {
    return Intl.message(
      'Are you sure you want to close the application?',
      name: 'closeDialogDetails',
      desc: '',
      args: [],
    );
  }

  /// `YES`
  String get closeDialogYes {
    return Intl.message(
      'YES',
      name: 'closeDialogYes',
      desc: '',
      args: [],
    );
  }

  /// `NO`
  String get closeDialogNo {
    return Intl.message(
      'NO',
      name: 'closeDialogNo',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logoutDialogTitle {
    return Intl.message(
      'Log out',
      name: 'logoutDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logoutDialogDetails {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logoutDialogDetails',
      desc: '',
      args: [],
    );
  }

  /// `YES`
  String get logoutDialogYes {
    return Intl.message(
      'YES',
      name: 'logoutDialogYes',
      desc: '',
      args: [],
    );
  }

  /// `NO`
  String get logoutDialogNo {
    return Intl.message(
      'NO',
      name: 'logoutDialogNo',
      desc: '',
      args: [],
    );
  }

  /// `Log Out failed`
  String get logoutDialogFailed {
    return Intl.message(
      'Log Out failed',
      name: 'logoutDialogFailed',
      desc: '',
      args: [],
    );
  }

  /// `Info`
  String get infoDialogTitle {
    return Intl.message(
      'Info',
      name: 'infoDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `CLOSE`
  String get infoDialogClose {
    return Intl.message(
      'CLOSE',
      name: 'infoDialogClose',
      desc: '',
      args: [],
    );
  }

  /// `In development`
  String get debugInDevelopment {
    return Intl.message(
      'In development',
      name: 'debugInDevelopment',
      desc: '',
      args: [],
    );
  }

  /// `Type your message...`
  String get typeYourMessage {
    return Intl.message(
      'Type your message...',
      name: 'typeYourMessage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}