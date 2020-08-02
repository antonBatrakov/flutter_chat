import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_list/models/groups_list_model.dart';
import 'package:flutter_chat/resources/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GroupListTab extends StatelessWidget {
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupListSource>(
      builder: (ctx, chatList, child) =>
          SmartRefresher(
            header: MaterialClassicHeader(),
            enablePullDown: true,
            onRefresh: () => _onRefresh(),
            controller: _refreshController,
            child: ListView.builder(
              itemCount: chatList.items.length,
              itemBuilder: (ctx, position) =>
                  GroupListItem(chatList.items[position]),
            ),
          ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    Fluttertoast.showToast(
      msg: DebugStrings.debugInDevelopment,
      backgroundColor: Colors.grey,
    );
    _refreshController.refreshCompleted();
  }
}

class GroupListItem extends StatelessWidget {
  final String _title;
  GroupListItem(this._title);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
    );
  }
}