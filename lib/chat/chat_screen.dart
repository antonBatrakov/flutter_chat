import 'package:flutter/material.dart';
import 'package:flutter_chat/chat/video_view.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/repository/chat_repository.dart';
import 'package:flutter_chat/resources/assets.dart';
import 'package:flutter_chat/util/firebase_const.dart';
import 'package:flutter_chat/util/hero_tags.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'chat_arg.dart';
import 'common/bottom_sheet.dart';
import 'models/chat_model.dart';

class ChatPage extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    ChatArg _arg = ModalRoute.of(context).settings.arguments;
    return ChangeNotifierProvider(
      create: (context) => ChatModel(
          Provider.of<ChatRepository>(context, listen: false), _arg.chat.id),
      builder: (context, child) => WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: ListTile(
              subtitle: Text(
                "online stub",
                style: TextStyle(color: Colors.white70),
              ),
              title: Text(
                _arg.chat.nickname,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              leading: Hero(
                tag: HeroTags.avatarTag + _arg.chat.id,
                child: CircleAvatar(
                  backgroundImage: _arg.chat?.photoUrl != null
                      ? NetworkImage(_arg.chat?.photoUrl)
                      : AssetImage(AuthImg.googleSignInLogo),
                ),
              ),
            ),
          ),
          body: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildListMessage(),
                buildInput(context),
              ],
            ),
          ),
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

  Widget buildItem(BuildContext context, int index, ChatMessageWithData message,
      int listLength) {
    if (message.isFromCurrentUser) {
      // Right (my message)
      return Row(
        children: <Widget>[
          message.type == ChatMessageType.Text
              // Text
              ? Container(
                  child: Linkify(
                    text: message.content,
                    linkStyle: TextStyle(
                        color: Colors.cyanAccent,
                        decoration: TextDecoration.underline),
                    style: TextStyle(color: Colors.blue),
                    onOpen: (link) {
                      _openWebPage(link, context);
                    },
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
                      bottom:
                          message.isFromCurrentUser && index == listLength - 1
                              ? 20.0
                              : 10.0,
                      right: 10.0),
                )
              : message.type == ChatMessageType.Map
                  // Map
                  ? Container(
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      height: 200.0,
                      child: buildMap(message.content[FirebaseConst.longitude],
                          message.content[FirebaseConst.latitude]),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.5))
                          ]),
                      margin: EdgeInsets.only(
                          bottom: message.isFromCurrentUser &&
                                  index == listLength - 1
                              ? 20.0
                              : 10.0,
                          right: 10.0),
                    )
                  // Video
                  : Container(
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      height: 200.0,
                      child: FutureBuilder<String>(
                        future: Provider.of<ChatModel>(context)
                            .getVideo(message.content),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error);
                          }
                          if (!snapshot.hasData || !(snapshot.data is String)) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return VideoView(videoFromWebToPlay: snapshot.data);
                          }
                        },
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.5))
                          ]),
                      margin: EdgeInsets.only(
                          bottom: message.isFromCurrentUser &&
                                  index == listLength - 1
                              ? 20.0
                              : 10.0,
                          right: 10.0),
                    ),
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
                        child: Linkify(
                            text: message.content,
                            linkStyle: TextStyle(
                                color: Colors.cyanAccent,
                                decoration: TextDecoration.underline),
                            style: TextStyle(color: Colors.white),
                            onOpen: (link) {
                              _openWebPage(link, context);
                            }),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    // Map
                    : message.type == ChatMessageType.Map
                        ? Container(
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(left: 10.0),
                            child: buildMap(
                                message.content[FirebaseConst.longitude],
                                message.content[FirebaseConst.latitude]),
                          )
                        :
                        // Video
                        Container(
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(left: 10.0),
                            child: FutureBuilder<String>(
                              future: Provider.of<ChatModel>(context)
                                  .getVideo(message.content),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(snapshot.error);
                                }
                                if (!snapshot.hasData ||
                                    !(snapshot.data is String)) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return VideoView(
                                      videoFromWebToPlay: snapshot.data);
                                }
                              },
                            ),
                          ),
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
                  context, index, value.messages[index], value.messages.length),
              itemCount: value.messages.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  _openWebPage(LinkableElement link, BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).appTitle),
          ),
          body: WebView(
            initialUrl: link.url,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
          ),
        ),
      ),
    ));
  }

  Widget buildMap(double longitude, double latitude) {
    return GoogleMap(
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: false,
        markers: {
          Marker(
              markerId: MarkerId(GoogleMapMarkIds.chatMarkId),
              position: LatLng(
                latitude,
                longitude,
              ))
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            latitude,
            longitude,
          ),
          zoom: 17,
        ));
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
                onPressed: () {
                  showModalBottomSheet(
                    enableDrag: true,
                    context: context,
                    builder: (_) => ChangeNotifierProvider<ChatModel>.value(
                      value: Provider.of<ChatModel>(context),
                      builder: (_, __) => ShareBottomSheet(),
                    ),
                  );
                },
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(fontSize: 15.0),
                controller: textEditingController,
                textCapitalization: TextCapitalization.sentences,
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
                onPressed: () => onSendMessage(context,
                    textEditingController.text, ChatMessageType.Text.index),
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
