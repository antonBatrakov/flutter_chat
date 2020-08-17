import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/chat_tab.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/groups_tab.dart';
import 'package:flutter_chat/chat_list/main_page_tabs/settings_tab.dart';
import 'package:flutter_chat/chat_list/models/chat_list_model.dart';
import 'package:flutter_chat/chat_list/models/groups_list_model.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      value: 1,
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        _fabAnimController.reverse();
      } else {
        _fabAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // todo fetch
          create: (ctx) => ChatListSource(),
        ),
        ChangeNotifierProvider(
          // todo fetch
          create: (ctx) => GroupListSource(),
        )
      ],
      builder: (ctx, child) => WillPopScope(
        onWillPop: () => _showCloseDialog(context),
        child: Scaffold(
          floatingActionButton: ScaleTransition(
            scale: _fabAnimController,
            child: FloatingActionButton(
              onPressed: () =>
                  Provider.of<ChatListSource>(ctx, listen: false).items = [],
              child: Icon(Icons.delete),
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _showCloseDialog(context),
            ),
            title: Text(ChatListScreenStrings.chatScreenTitle),
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.chat),
                  text: ChatListScreenStrings.chatScreenChats,
                ),
                Tab(
                  icon: Icon(Icons.group),
                  text: ChatListScreenStrings.chatScreenGroups,
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: ChatListScreenStrings.chatScreenSettings,
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
            title: Text(CloseDialogStrings.closeDialogTitle),
            content: Text(CloseDialogStrings.closeDialogDetails),
            actions: <Widget>[
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: Text(
                      CloseDialogStrings.closeDialogYes,
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      CloseDialogStrings.closeDialogNo,
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
    return Container(
      
    );
  }
}