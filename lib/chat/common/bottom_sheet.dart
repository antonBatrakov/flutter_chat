import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat/common/video_attach.dart';
import 'package:flutter_chat/chat/models/chat_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:flutter_chat/util/firebase_const.dart';
import 'package:flutter_chat/util/permissions.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
                                return VideoAttach(snapshot.data);
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
}