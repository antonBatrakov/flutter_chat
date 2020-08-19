import 'dart:core';
import 'dart:ui';
import 'package:built_value/built_value.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/chat_list/models/lang_model.dart';

extension LocalesMapping on List<Locale> {
  List<LocaleModel> toLocalesModel() {
    return this.map((locale) {
      return locale.toLocaleModel();
    }).toList();
  }
}

extension LocaleMapping on Locale {
  LocaleModel toLocaleModel() {
    String languageName;
    if (this.compareWithCode("ru")) {
      languageName = "Русский";
    } else if (this.compareWithCode("en")) {
      languageName = "English";
    } else {
      languageName = "";
    }
    return LocaleModel(langName: languageName, locale: this);
  }

  bool compareWithCode(String code) =>
      this.languageCode?.toLowerCase() == code ||
      this.countryCode?.toLowerCase() == code;
}

extension ListExt<T> on List<T> {
  @nullable
  T find(bool Function(T) predicate) {
    T foundElement;
    this.forEach((element) {
      if (predicate(element)) {
        foundElement = element;
      }
    });

    return foundElement;
  }
}
