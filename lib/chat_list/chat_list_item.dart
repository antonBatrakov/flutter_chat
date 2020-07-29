import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String _title;
  ChatListItem(this._title);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
    );
  }
}
