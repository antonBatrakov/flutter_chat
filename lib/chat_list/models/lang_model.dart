
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/resources/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangChangeNotifier extends ChangeNotifier {

  SharedPreferences _prefs;

  Locale chosenLocale;

  LangChangeNotifier()  {
    loadLang();
  }

  loadLang() async {
    _prefs = await SharedPreferences.getInstance();
    final locale = _prefs.getString(PrefsConst.language);
    if (locale != null) {
      updateLang(Locale(locale));
    }
  }

  updateLang(Locale locale) {
    chosenLocale = locale;
    // S.load(locale);
    _prefs?.setString(PrefsConst.language, locale.languageCode);
    notifyListeners();
  }
}

class LocaleModel {
  LocaleModel({this.locale, this.langName});
  final String langName;
  final Locale locale;
}