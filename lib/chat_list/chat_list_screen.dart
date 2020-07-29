import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/chat_list/chat_list.dart';
import 'package:flutter_chat/chat_list/chat_list_item.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ChangeNotifierProvider(
      create: (ctx) => ChatListSource(),
      builder: (ctx, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Provider.of<ChatListSource>(ctx, listen: false).items = [],
          child: Icon(Icons.delete),
        ),
        appBar: AppBar(
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
            ChatListView(),
            ChatListView(),
            ChatListView(),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}

class ChatListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListSource>(
      builder: (ctx, chatList, child) => ListView.builder(
        itemCount: chatList.items.length,
        itemBuilder: (ctx, position) => ChatListItem(chatList.items[position]),
      ),
    );
  }
}
