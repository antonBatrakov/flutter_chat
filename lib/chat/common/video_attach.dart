import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat/chat/models/chat_model.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../video_view.dart';

class VideoAttach extends StatelessWidget {
  VideoAttach(this._videoToPlay);

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
