import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/chat_list/models/settings_model.dart';
import 'package:flutter_chat/models/multiple_select.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:flutter_chat/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {

  final UserRepository _userRepository = UserRepository();

  List<SettingsModel> settingsList;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    settingsList = [
      SettingsModel.userSettings(_userRepository),
      SettingsModel.boolSetting("Mute notifications"),
      SettingsModel.multipleChoiceSetting("Language", [
        // todo real locales
        MultipleSelectValue("English", false),
        MultipleSelectValue("English1", false),
        MultipleSelectValue("English2", true),
        MultipleSelectValue("English3", false),
        MultipleSelectValue("English4", false),
        MultipleSelectValue("English5", false),
        MultipleSelectValue("English6", false),
      ]),
      SettingsModel.logOutSettings("Log out"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: settingsList.length,
      itemBuilder: (ctx, position) =>
          _settingsWidget(ctx, settingsList[position]),
    );
  }

  @override
  void dispose() {
    settingsList.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      settingsList.add(SettingsModel.simpleSetting(
          "Version: ${info.version} ${info.buildNumber}"));
    });
  }

  _showLogoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(LogoutDialogStrings.logoutDialogTitle),
              content: Text(LogoutDialogStrings.logoutDialogDetails),
              actions: <Widget>[
                ChangeNotifierProvider(
                  create: (_) => SignOutModel(_userRepository),
                  child: ButtonBar(
                    children: <Widget>[
                      Consumer<SignOutModel>(
                        builder: (ctx, value, child) {
                          switch (value.result) {
                            case SignOutResult.success:
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pushReplacementNamed(
                                    ctx, RouteNames.authScreen);
                              });
                              break;
                            case SignOutResult.failed:
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(ctx).pop();
                              });
                              Fluttertoast.showToast(
                                  backgroundColor: Colors.grey,
                                  msg: LogoutDialogStrings.logoutDialogFailed,
                                  toastLength: Toast.LENGTH_SHORT);
                              break;
                            default:
                          }
                          return FlatButton(
                            onPressed: () {
                              value.signOut();
                            },
                            child: Text(
                              LogoutDialogStrings.logoutDialogYes,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                            ),
                          );
                        },
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          LogoutDialogStrings.logoutDialogNo,
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
  }

  Widget _settingsWidget(BuildContext context, SettingsModel settingsModel) {
    if (settingsModel is SimpleSettingsModel) {
      return _simpleSettings(settingsModel);
    } else if (settingsModel is BoolSettingsModel) {
      return _boolSettings(settingsModel);
    } else if (settingsModel is MultipleChooseSettingsModel) {
      return _multipleChoiceSettings(settingsModel);
    } else if (settingsModel is UserSettingsModel) {
      return _userSettings(settingsModel);
    } else if (settingsModel is LogOutSettingsModel) {
      return _logOutSettings(context, settingsModel);
    }
    return null;
  }

  Widget _logOutSettings(
          BuildContext context, LogOutSettingsModel settingsModel) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Text(settingsModel.settingName),
            onTap: () => _showLogoutDialog(context),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _userSettings(UserSettingsModel settingsModel) =>
      StreamBuilder(
        stream: settingsModel.user,
        initialData: ChatUser("", ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data is ChatUser) {
            return Column(
              children: <Widget>[
                ListTile(
                  onTap: () =>
                      Fluttertoast.showToast(
                        msg: DebugStrings.debugInDevelopment,
                        backgroundColor: Colors.grey,
                      ),
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    (snapshot.data as ChatUser).name,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        (snapshot.data as ChatUser).imgUrl),
                    backgroundColor: Colors.grey,
                  ),
                ),
                Divider(
                  height: 1,
                ),
              ],
            );
          } else {
            return ListTile(
              title: Text(SettingsScreenStrings.settingsScreenFetching),
            );
          }
        },
      );

  Widget _boolSettings(BoolSettingsModel settingsModel) =>
      Column(
        children: <Widget>[
          StreamBuilder(
            stream: settingsModel.value,
            builder: (context, snapshot) =>
                ListTile(
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: DebugStrings.debugInDevelopment,
                      backgroundColor: Colors.grey,
                    );
                    settingsModel
                        .updateValue(
                        snapshot.data is bool ? !snapshot.data : false);
                  },
                  title: Text(settingsModel.settingName),
                  trailing: Switch(
                    value: snapshot.data is bool ? snapshot.data : false,
                    onChanged: (newValue) =>
                        settingsModel.updateValue(newValue),
                  ),
                ),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _simpleSettings(SimpleSettingsModel settingsModel) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Text(settingsModel.settingName),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _multipleChoiceSettings(MultipleChooseSettingsModel settingsModel) =>
      StreamBuilder(
        stream: settingsModel.chosenValue,
        builder: (context, snapshot) =>
            Column(
              children: <Widget>[
                ListTile(
                  onTap: () =>
                      showDialog(
                        context: context,
                        child: _createMultiSelectDialog(
                            settingsModel.valueOptions, settingsModel),
                      ),
                  title: Text(settingsModel.settingName),
                  trailing: Text(snapshot.data is MultipleSelectValue
                      ? snapshot.data.value
                      : ""),
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
      );

  Widget _createMultiSelectDialog(List<MultipleSelectValue> items,
      MultipleChooseSettingsModel settingsModel) =>
      AlertDialog(
        title: Text(SettingsScreenStrings.settingsScreenChangeLangTitle),
        content: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: DebugStrings.debugInDevelopment,
                        backgroundColor: Colors.grey,
                      );
                      settingsModel.updateValue(items[index]);
                      Navigator.pop(context);
                    },
                    selected: items[index].isSelected,
                    leading: Radio(
                      visualDensity: VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: items[index].isSelected,
                      groupValue: true,
                      onChanged: (_) {},
                    ),
                    title: Text(items[index].value),
                  ),
                  Divider(
                    height: 1,
                  ),
                ],
              ),
        ),
      );
}