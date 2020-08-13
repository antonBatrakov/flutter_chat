import 'dart:async';

import 'package:flutter_chat/models/multiple_select.dart';
import 'package:flutter_chat/models/user_model.dart';

abstract class SettingsModel {
  SettingsModel._();

  factory SettingsModel.simpleSetting(String name) = SimpleSettingsModel;
  factory SettingsModel.boolSetting(String name) = BoolSettingsModel;
  factory SettingsModel.logOutSettings(String name) = LogOutSettingsModel;
  factory SettingsModel.userSettings() = UserSettingsModel;
  factory SettingsModel.multipleChoiceSetting(
          String name, List<MultipleSelectValue<String>> valueOptions) =
      MultipleChooseSettingsModel;

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

class MultipleChooseSettingsModel extends SettingsModel {
  MultipleChooseSettingsModel(this.settingName, this.valueOptions) : super._() {
    // todo read value from prefs
    updateValue(valueOptions.firstWhere((element) => element.isSelected));
  }

  final String settingName;
  List<MultipleSelectValue<String>> valueOptions;

  final StreamController<MultipleSelectValue<String>> _chosenValueController =
      StreamController<MultipleSelectValue<String>>();

  Stream<MultipleSelectValue<String>> get chosenValue =>
      _chosenValueController.stream;

  updateValue(MultipleSelectValue<String> newValue) {
    // todo save value to prefs
    valueOptions = valueOptions.map((MultipleSelectValue<String> e) {
      MultipleSelectValue<String> updatedValue = e;
      updatedValue.isSelected = (e == newValue);
      return updatedValue;
    }).toList();
    _chosenValueController.sink.add(newValue);
  }

  @override
  dispose() {
    _chosenValueController.close();
  }
}

class UserSettingsModel extends SettingsModel {
  UserSettingsModel() : super._() {
    _userStreamController.sink.add(User("kek",
        "https://avatars2.githubusercontent.com/u/65542314?s=460&u=76a8f688a9405f0af241c8147a35292e8f16f686&v=4"));
  }

  final StreamController<User> _userStreamController = StreamController<User>();

  Stream<User> get user => _userStreamController.stream;

  @override
  void dispose() {
    _userStreamController.close();
  }
}

class LogOutSettingsModel extends SettingsModel {
  LogOutSettingsModel(this.settingName) : super._();
  final String settingName;

  logOut() {
    // todo clean prefs
  }

  @override
  dispose() {}
}
