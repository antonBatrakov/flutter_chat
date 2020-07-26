import 'package:flutter/material.dart';

class ChatListItem extends StatefulWidget {
  final String _title;
  ChatListItem(this._title);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget._title),
    );
  }
}
