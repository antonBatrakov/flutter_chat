import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat/video_view.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/repository/chat_repository.dart';
import 'package:flutter_chat/util/firebase_const.dart';
import 'package:flutter_chat/util/hero_tags.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
                  backgroundImage: NetworkImage(_arg.chat?.photoUrl ?? ""),
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
                                  return Center(child: CircularProgressIndicator());
                                } else {
                                  return VideoView(videoFromWebToPlay: snapshot.data);
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

class ShareBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: true,
      onClosing: () {},
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      PermissionStatus status =
                          await requestLocationPermission(context);
                      if (status == PermissionStatus.granted) {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              ChangeNotifierProvider<ChatModel>.value(
                            value: Provider.of<ChatModel>(context),
                            builder: (context, child) => AlertDialog(
                              title:
                                  Text(S.of(context).locationDialogSearching),
                              content: FutureBuilder<LocationData>(
                                future: Location().getLocation(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    Navigator.of(context).pop();
                                    return Container(
                                      height: 200,
                                      child: Text(
                                        snapshot.error,
                                      ),
                                    );
                                  } else {
                                    Provider.of<ChatModel>(context,
                                            listen: false)
                                        .sendMessage({
                                      FirebaseConst.longitude:
                                          snapshot.data.longitude,
                                      FirebaseConst.latitude:
                                          snapshot.data.latitude,
                                    }, ChatMessageType.Map.index);
                                    Navigator.of(context).pop();
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                Text(S.of(context).chatBottomSheetShareLocation),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.perm_media,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    PermissionStatus status =
                        await requestStoragePermission(context);
                    if (status == PermissionStatus.granted) {
                      showDialog(
                        context: context,
                        builder: (_) => ChangeNotifierProvider<ChatModel>.value(
                          value: Provider.of<ChatModel>(context),
                          builder: (context, child) => FutureBuilder<String>(
                            future: FilePicker.getFilePath(
                              type: FileType.video,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                Navigator.of(context).pop();
                                return Container(
                                  height: 200,
                                  child: Text(
                                    snapshot.error,
                                  ),
                                );
                              } else {
                                return _VideoAttach(snapshot.data);
                              }
                            },
                          ),
                        ),
                      );
                    }
                  }),
              Text(
                S.of(context).chatBottomSheetShareMedia,
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<PermissionStatus> requestLocationPermission(
      BuildContext context) async {
    final PermissionStatus permissionRequestResult =
        await Permission.location.request();
    if (permissionRequestResult != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).locationDialogTitle),
          content: Text(S.of(context).locationDialogContent),
          actions: [
            FlatButton(
                onPressed: () => {Navigator.of(context).pop()},
                child: Text(S.of(context).locationDialogNo)),
            FlatButton(
                onPressed: () async {
                  bool isOpened = await openAppSettings();
                  if (isOpened) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(S.of(context).locationDialogYes))
          ],
        ),
      );
    }

    return await Permission.location.status;
  }

  Future<PermissionStatus> requestStoragePermission(
      BuildContext context) async {
    final PermissionStatus permissionRequestResult =
        await Permission.storage.request();
    if (permissionRequestResult != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).storageDialogTitle),
          content: Text(S.of(context).storageDialogContent),
          actions: [
            FlatButton(
                onPressed: () => {Navigator.of(context).pop()},
                child: Text(S.of(context).storageDialogNo)),
            FlatButton(
                onPressed: () async {
                  bool isOpened = await openAppSettings();
                  if (isOpened) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(S.of(context).storageDialogNo))
          ],
        ),
      );
    }

    return await Permission.storage.status;
  }
}

class _VideoAttach extends StatelessWidget {
  _VideoAttach(this._videoToPlay);

  final String _videoToPlay;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 8,
              child: VideoView(videoToPlay: _videoToPlay),
            ),
            Expanded(
              flex: 1,
              child: ChangeNotifierProvider.value(
                value: Provider.of<ChatModel>(context),
                builder: (context, child) {
                  return Consumer<ChatModel>(
                    builder: (context, value, child) {
                      if (value.sendingProgress == 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: FlatButton(
                                minWidth: double.infinity,
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(S.of(context).storageDialogNo),
                                textColor: Colors.blueAccent,
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                  minWidth: double.infinity,
                                  color: Colors.black,
                                  onPressed: () async {
                                    Provider.of<ChatModel>(context,
                                            listen: false)
                                        .sendMessage(File(_videoToPlay),
                                            ChatMessageType.Video.index);
                                  },
                                  child: Text(S.of(context).storageDialogSend),
                                  textColor: Colors.blue),
                            )
                          ],
                        );
                      } else if (value.sendingProgress == 1) {
                        Navigator.pop(context);
                        return Container();
                      } else {
                        return LinearProgressIndicator(
                          value: value.sendingProgress,
                        );
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
}
