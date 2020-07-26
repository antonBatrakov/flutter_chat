import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_list/chat_list.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatListPage(title: 'Flutter Chat'),
    );
  }
}

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
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
      create: (ctx) => ChatList(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
    final chatList = Provider.of<ChatList>(context);
    return ListView.builder(
      itemCount: chatList.items.length,
      itemBuilder: (ctx, position) =>
          ChatListItemView(chatList.items[position]),
    );
  }
}

class ChatListItemView extends StatefulWidget {
  ChatListItemView(this._title);

  final String _title;

  @override
  _ChatListItemViewState createState() => _ChatListItemViewState();
}

class _ChatListItemViewState extends State<ChatListItemView> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget._title),
    );
  }
}
