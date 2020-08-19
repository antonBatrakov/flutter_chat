import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/util/firebase_const.dart';
import 'package:flutter_chat/util/hero_tags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_arg.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();

}

class _ChatPageState extends State<ChatPage> {
  ChatArg _arg;

  final User currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  SharedPreferences prefs;

  String groupChatId;

  List<QueryDocumentSnapshot> listMessage;

  @override
  void initState() {
    super.initState();
    groupChatId = "";
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    _arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
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
            tag: HeroTags.avatarTag,
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
          buildInput(),
        ],
      ),
    );
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    if (currentUser.uid.hashCode <= _arg.chat.id.hashCode) {
      groupChatId = '${currentUser.uid}-${_arg.chat.id}';
    } else {
      groupChatId = '${_arg.chat.id}-${currentUser.uid}';
    }

    FirebaseFirestore.instance.collection(FirebaseConst.users).doc(currentUser.uid).update({'chattingWith': _arg.chat.id});

    setState(() {});
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection(FirebaseConst.messages)
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            FirebaseConst.idFrom: FirebaseAuth.instance.currentUser.uid,
            FirebaseConst.idTo: _arg.chat.id,
            FirebaseConst.timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
            FirebaseConst.content: content,
            FirebaseConst.type: type
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()[FirebaseConst.idFrom] == currentUser.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data()[FirebaseConst.type] == 0
          // Text
              ? Container(
            child: Text(
              document.data()[FirebaseConst.content],
              style: TextStyle(color: Colors.blue),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5))]),
            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
              : document.data()[FirebaseConst.type] == 1
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
                document.data()[FirebaseConst.type] == 0
                    ? Container(
                  child: Text(
                    document.data()[FirebaseConst.content],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
                // Map
                    : document.data()[FirebaseConst.type] == 1
                    ? Container()
                // Video
                    : Container(),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()[FirebaseConst.timestamp]))),
                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
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

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1].data()[FirebaseConst.idFrom] == currentUser.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1].data()[FirebaseConst.idFrom] != currentUser.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
          : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirebaseConst.messages)
            .doc(groupChatId)
            .collection(groupChatId)
            .orderBy(FirebaseConst.timestamp, descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildInput() {
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
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
    );
  }
}
