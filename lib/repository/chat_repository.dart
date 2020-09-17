import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat/util/firebase_const.dart';
import 'package:path_provider/path_provider.dart';

class ChatRepository {
  void updateChattingWith(String chatId) {
    FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({FirebaseConst.chattingWith: chatId});
  }

  Future<Stream<StorageTaskEvent>> _uploadVideo(File video) async {
    final StorageReference storageReference = FirebaseStorage()
        .ref()
        .child(FirebaseConst.videoPath + video.hashCode.toString() + ".mp4");

    final StorageUploadTask uploadTask =
        storageReference.putData(await video.readAsBytes());
    return uploadTask.events;
  }

  Future<dynamic> sendMessage(String groupChatId, String chatId,
      User currentUser, dynamic content, int type) async {
    var documentReference = FirebaseFirestore.instance
        .collection(FirebaseConst.messages)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          FirebaseConst.idFrom: currentUser.uid,
          FirebaseConst.idTo: chatId,
          FirebaseConst.timestamp:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirebaseConst.content: (content is File)
              ? FirebaseConst.videoPath + content.hashCode.toString() + ".mp4"
              : content,
          FirebaseConst.type: type
        },
      );
    });

    if (content is File) {
      return (await _uploadVideo(content));
    }
    return true;
  }

  Stream<QuerySnapshot> getChatMessages(String groupChatId) =>
      FirebaseFirestore.instance
          .collection(FirebaseConst.messages)
          .doc(groupChatId)
          .collection(groupChatId)
          .orderBy(FirebaseConst.timestamp, descending: true)
          .limit(20)
          .snapshots();

  Future<String> getVideo(String path) async {
    final StorageReference storageReference = FirebaseStorage()
        .ref()
        .child(path);
    String reference = await storageReference.getDownloadURL();
    return reference;
  }
}
