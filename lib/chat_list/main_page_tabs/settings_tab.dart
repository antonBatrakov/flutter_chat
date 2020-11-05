import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_chat/api/info_api.dart';
import 'package:flutter_chat/api/model/post.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/settings_key_value.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/chat_list/models/lang_model.dart';
import 'package:flutter_chat/chat_list/models/settings_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/models/multiple_select.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:flutter_chat/resources/assets.dart';
import 'package:flutter_chat/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  List<SettingsModel> settingsList;

  @override
  void initState() {
    super.initState();
    settingsList = [
      SettingsModel.userSettings(),
      SettingsModel.boolSetting("Mute notifications"),
      SettingsModel.languageSetting(),
      SettingsModel.infoSettings(),
      SettingsModel.logOutSettings(),
    ];
    _initPackageInfo();
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

  Widget _settingsWidget(BuildContext context, SettingsModel settingsModel) {
    if (settingsModel is SimpleSettingsModel) {
      return _simpleSettings(settingsModel);
    } else if (settingsModel is BoolSettingsModel) {
      return _boolSettings(settingsModel);
    } else if (settingsModel is UserSettingsModel) {
      return _userSettings(settingsModel);
    } else if (settingsModel is LogOutSettingsModel) {
      return _logOutSettings(context, settingsModel);
    } else if (settingsModel is InfoSettingsModel) {
      return _infoSettings(context);
    } else if (settingsModel is LanguageSettingsModel) {
      return _languageSetting(context, settingsModel);
    }
    return null;
  }

  _showLogoutDialog(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(S.of(context).logoutDialogTitle),
              content: Text(S.of(context).logoutDialogDetails),
              actions: <Widget>[
                ChangeNotifierProvider(
                  create: (_) => AuthModel(userRepository),
                  child: ButtonBar(
                    children: <Widget>[
                      Consumer<AuthModel>(
                        builder: (ctx, value, child) {
                          switch (value.result) {
                            case AuthResult.signedOut:
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pushReplacementNamed(
                                    ctx, RouteNames.authScreen);
                              });
                              break;
                            case AuthResult.failed:
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(ctx).pop();
                              });
                              Fluttertoast.showToast(
                                  backgroundColor: Colors.grey,
                                  msg: S.of(context).logoutDialogFailed,
                                  toastLength: Toast.LENGTH_SHORT);
                              break;
                            default:
                          }
                          return FlatButton(
                            onPressed: () {
                              value.signOut();
                            },
                            child: Text(
                              S.of(context).logoutDialogYes,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                            ),
                          );
                        },
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          S.of(context).logoutDialogNo,
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
  }

  _showInfoDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => FutureBuilder<Response<PostModel>>(
              future: Provider.of<InfoService>(context).getInfo(7),
              builder: (context, snapshot) => AlertDialog(
                title: Text(S.of(context).infoDialogTitle),
                content: _infoDialogContent(snapshot),
                actions: [
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context).infoDialogClose),
                  )
                ],
              ),
            ));
  }

  Widget _infoDialogContent(AsyncSnapshot<Response<PostModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(
          child: Text(
            snapshot.error.toString(),
            textAlign: TextAlign.center,
          ),
        );
      }

      final post = snapshot.data.body;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.title,
            style: TextStyle(fontSize: 24),
          ),
          Text(post.body),
        ],
      );
    } else {
      return Center(
        heightFactor: 4,
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _logOutSettings(
          BuildContext context, LogOutSettingsModel settingsModel) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Text(S.of(context).settingsScreenLogout),
            onTap: () => _showLogoutDialog(context),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _userSettings(UserSettingsModel settingsModel) {
    final user = Provider.of<UserRepository>(context, listen: false).getUser();
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () => Fluttertoast.showToast(
            msg: S.of(context).debugInDevelopment,
            backgroundColor: Colors.grey,
          ),
          contentPadding: EdgeInsets.all(10),
          title: Text(
            (user.displayName != null && user.displayName.isNotEmpty)
                ? user.displayName
                : user.email,
          ),
          leading: CircleAvatar(
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL)
                : AssetImage(AuthImg.googleSignInLogo),
            backgroundColor: Colors.grey,
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }

  Widget _boolSettings(BoolSettingsModel settingsModel) => Column(
        children: <Widget>[
          StreamBuilder(
            stream: settingsModel.value,
            builder: (context, snapshot) => ListTile(
              onTap: () {
                Fluttertoast.showToast(
                  msg: S.of(context).debugInDevelopment,
                  backgroundColor: Colors.grey,
                );
                settingsModel.updateValue(
                    snapshot.data is bool ? !snapshot.data : false);
              },
              title: Text(settingsModel.settingName),
              trailing: Switch(
                value: snapshot.data is bool ? snapshot.data : false,
                onChanged: (newValue) => settingsModel.updateValue(newValue),
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _simpleSettings(SimpleSettingsModel settingsModel) => Column(
        children: <Widget>[
          ListTile(
            title: Text(settingsModel.settingName),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _createLangSelectDialog(List<MultipleSelectValue<LocaleModel>> items,
          LanguageSettingsModel settingsModel) =>
      AlertDialog(
        title: Text(S.of(context).settingsScreenChangeLangTitle),
        content: Container(
          width: 400,
          child: ListView.builder(
            key: ValueKey(SettingsKeys.langList),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  key: Key(items[index].value.langName),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: S.of(context).debugInDevelopment,
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
                  title: Text(items[index].value.langName),
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _infoSettings(BuildContext context) => Column(
        children: <Widget>[
          ListTile(
            title: Text(S.of(context).infoDialogTitle),
            onTap: () => _showInfoDialog(context),
          ),
          Divider(
            height: 1,
          ),
        ],
      );

  Widget _languageSetting(
      BuildContext context, LanguageSettingsModel settingsModel) {
    settingsModel.langChangeNotifier =
        Provider.of<LangChangeNotifier>(context, listen: false);

    return StreamBuilder<MultipleSelectValue<LocaleModel>>(
      stream: settingsModel.chosenValue,
      builder: (context, snapshot) => Column(
        children: <Widget>[
          ListTile(
            key: ValueKey(SettingsKeys.langTile),
            onTap: () => showDialog(
              context: context,
              child: _createLangSelectDialog(
                  settingsModel.valueOptions, settingsModel),
            ),
            title: Text(S.of(context).settingsScreenChangeLangTitle),
            trailing: Text(snapshot.data is MultipleSelectValue
                ? snapshot.data.value.langName
                : "",
              key: Key(SettingsKeys.langTileTrailing),
            ),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
