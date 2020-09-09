import 'package:flutter/material.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/repository/chat_repository.dart';
import 'package:flutter_chat/util/hero_tags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'chat_arg.dart';
import 'models/chat_model.dart';

class ChatPage extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    ChatArg _arg = ModalRoute.of(context).settings.arguments;
    return ChangeNotifierProvider(
      create: (context) =>
          ChatModel(Provider.of<ChatRepository>(context, listen: false), _arg.chat.id),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: ListTile(
            subtitle: Text(
              "online",
              style: TextStyle(color: Colors.white70),
            ),
            title: Text(
              _arg.chat.nickname,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            leading: Hero(
              tag: HeroTags.avatarTag + _arg.chat.id,
              child: CircleAvatar(
                backgroundImage: NetworkImage(_arg.chat?.photoUrl ?? ""),
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            buildListMessage(),
            buildInput(context),
          ],
        ),
      ),
    );
  }

  void onSendMessage(BuildContext context, String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();
      Provider.of<ChatModel>(context, listen: false).sendMessage(content, type);

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, ChatMessageWithData message, int listLength) {
    if (message.isFromCurrentUser) {
      // Right (my message)
      return Row(
        children: <Widget>[
          message.type == ChatMessageType.Text
              // Text
              ? Container(
                  child: Text(
                    message.content,
                    style: TextStyle(color: Colors.blue),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.5))
                      ]),
                  margin: EdgeInsets.only(
                      bottom: message.isFromCurrentUser && index == listLength - 1
                          ? 20.0
                          : 10.0,
                      right: 10.0),
                )
              : message.type == ChatMessageType.Map
                  // Map
                  ? Container()
                  // Video
                  : Container(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                message.type == ChatMessageType.Text
                    ? Container(
                        child: Text(
                          message.content,
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    // Map
                    : message.type == ChatMessageType.Map
                        ? Container()
                        // Video
                        : Container(),
              ],
            ),

            // Time
            !message.isFromCurrentUser
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(message.timeStamp))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 8.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: Consumer<ChatModel>(
        builder: (context, value, child) {
          if (value.messages.isEmpty) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(
                  index, value.messages[index], value.messages.length),
              itemCount: value.messages.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildInput(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () {},
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.blue, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: S.of(context).typeYourMessage,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(context, textEditingController.text, 0),
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }
}
