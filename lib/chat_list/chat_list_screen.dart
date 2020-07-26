import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_list/chat_list.dart';
import 'package:flutter_chat/chat_list/chat_list_item.dart';
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
    return ChangeNotifierProvider(
      create: (ctx) => ChatListSource(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat list"),
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.chat),
                text: "chat",
              ),
              Tab(
                icon: Icon(Icons.group),
                text: "group",
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: "settings",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[ChatListView(), ChatListView(), ChatListView()],
          controller: _tabController,
        ),
      ),
    );
  }
}

class ChatListView extends StatefulWidget {
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    final chatList = Provider.of<ChatListSource>(context);
    return ListView.builder(
      itemCount: chatList.items.length,
      itemBuilder: (ctx, position) => ChatListItem(chatList.items[position]),
    );
  }
}
