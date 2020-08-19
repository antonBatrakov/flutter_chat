import 'dart:async';

import 'package:flutter_chat/chat_list/models/lang_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/models/multiple_select.dart';
import 'package:flutter_chat/resources/prefs.dart';
import 'package:flutter_chat/util/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsModel {
  SettingsModel._();

  factory SettingsModel.simpleSetting(String name) = SimpleSettingsModel;

  factory SettingsModel.boolSetting(String name) = BoolSettingsModel;

  factory SettingsModel.logOutSettings() = LogOutSettingsModel;

  factory SettingsModel.infoSettings() = InfoSettingsModel;

  factory SettingsModel.userSettings() = UserSettingsModel;

  factory SettingsModel.languageSetting() = LanguageSettingsModel;

  dispose();
}

class SimpleSettingsModel extends SettingsModel {
  SimpleSettingsModel(this.settingName) : super._();

  final String settingName;

  @override
  dispose() {}
}

class BoolSettingsModel extends SettingsModel {
  BoolSettingsModel(this.settingName) : super._() {
    // todo read value from prefs
    updateValue(false);
  }

  final String settingName;
  final _boolStreamController = StreamController<bool>();

  Stream<bool> get value => _boolStreamController.stream;

  updateValue(bool newValue) {
    // todo save value to prefs
    _boolStreamController.sink.add(newValue);
  }

  @override
  void dispose() {
    _boolStreamController.close();
  }
}

class UserSettingsModel extends SettingsModel {
  UserSettingsModel() : super._();

  @override
  void dispose() {}
}

class LogOutSettingsModel extends SettingsModel {
  LogOutSettingsModel() : super._();

  @override
  dispose() {}
}

class InfoSettingsModel extends SettingsModel {
  InfoSettingsModel() : super._();

  @override
  dispose() {}
}

class LanguageSettingsModel extends SettingsModel {
  LanguageSettingsModel() : super._() {
    final languagesModel = S.delegate.supportedLocales.toLocalesModel();
    valueOptions =
        languagesModel.map((e) => MultipleSelectValue(e, false)).toList();
    _updateFromPrefs();
  }

  List<MultipleSelectValue<LocaleModel>> valueOptions;

  LangChangeNotifier _langChangeNotifier;

  set langChangeNotifier(LangChangeNotifier notifier) =>
      _langChangeNotifier = notifier;

  final StreamController<MultipleSelectValue<LocaleModel>>
      _chosenValueController =
      StreamController<MultipleSelectValue<LocaleModel>>();

  Stream<MultipleSelectValue<LocaleModel>> get chosenValue =>
      _chosenValueController.stream;

  updateValue(MultipleSelectValue<LocaleModel> newValue) {
    valueOptions = valueOptions?.map((MultipleSelectValue<LocaleModel> e) {
      MultipleSelectValue<LocaleModel> updatedValue = e;
      updatedValue.isSelected = (e == newValue);
      return updatedValue;
    })?.toList();
    _langChangeNotifier?.updateLang(newValue.value.locale);
    _chosenValueController.sink.add(newValue);
  }

  @override
  dispose() {
    _chosenValueController.close();
  }

  _updateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = prefs.getString(PrefsConst.language);
    if (currentLocale != null) {
      final supportedChosenLocale = valueOptions.find(
          (element) => element.value.locale.compareWithCode(currentLocale));
      if (supportedChosenLocale != null) {
        updateValue(supportedChosenLocale);
      }
    }
  }
}
