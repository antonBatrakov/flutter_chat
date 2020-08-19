import 'package:flutter/material.dart';
import 'package:flutter_chat/chat/chat_arg.dart';
import 'package:flutter_chat/chat_list/models/chat_list_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/routes.dart';
import 'package:flutter_chat/util/hero_tags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatListTab extends StatefulWidget {
  @override
  _ChatListTabState createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListSource(),
      builder: (context, _) => Consumer<ChatListSource>(
        builder: (ctx, chatList, child) => SmartRefresher(
          enablePullDown: true,
          onRefresh: () => _onRefresh(context),
          controller: _refreshController,
          child: StreamBuilder<List<Chat>>(
              stream: chatList.items,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (ctx, position) =>
                        ChatListItem(snapshot.data[position]),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }

  void _onRefresh(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 1000));
    Fluttertoast.showToast(
      msg: S.of(context).debugInDevelopment,
      backgroundColor: Colors.grey,
    );
    _refreshController.refreshCompleted();
  }
}

class ChatListItem extends StatelessWidget {
  final Chat _chat;

  ChatListItem(this._chat);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, RouteNames.chatScreen,
                arguments: ChatArg(_chat));
          },
          leading: Hero(
            tag: HeroTags.avatarTag,
            child: CircleAvatar(
              backgroundImage: NetworkImage(_chat?.photoUrl ?? ""),
            ),
          ),
          title: Text(
            _chat?.nickname ?? "",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          subtitle: Text("last message"),
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }
}
