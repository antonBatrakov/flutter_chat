import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/chat_tab.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/groups_tab.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/settings_tab.dart';
import 'package:flutter_chat/chat_list/main_screen_keys.dart';
import 'package:flutter_chat/chat_list/models/groups_list_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => GroupListSource(),
        )
      ],
      builder: (ctx, child) => WillPopScope(
        onWillPop: () => _showCloseDialog(context),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _showCloseDialog(context),
            ),
            title: Text(S.of(context).chatScreenTitle),
            bottom: TabBar(
              key: ValueKey(MainScreenKeys.mainTabBar),
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.chat),
                  child: Text(S.of(context).chatScreenChats),
                ),
                Tab(
                  icon: Icon(Icons.group),
                  child: Text(S.of(context).chatScreenGroups),
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  child: Text(
                    S.of(context).chatScreenSettings,
                    key: Key(MainScreenKeys.settingsTab),
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Scrollbar(child: ChatListTab()),
              GroupListTab(),
              SettingsTab(),
            ],
            controller: _tabController,
          ),
        ),
      ),
    );
  }
}

_showCloseDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(S.of(context).closeDialogTitle),
            content: Text(S.of(context).closeDialogDetails),
            actions: <Widget>[
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: Text(
                      S.of(context).closeDialogYes,
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      S.of(context).closeDialogNo,
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              )
            ],
          ));
}

class Kek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
