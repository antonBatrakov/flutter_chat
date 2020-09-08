import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/util/firebase_const.dart';

class ChatRepository {
  void updateChattingWith(String chatId) {
    FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({FirebaseConst.chattingWith: chatId});
  }

  Stream<QuerySnapshot> getChatMessages(String groupChatId) => FirebaseFirestore.instance
      .collection(FirebaseConst.messages)
      .doc(groupChatId)
      .collection(groupChatId)
      .orderBy(FirebaseConst.timestamp, descending: true)
      .limit(20)
      .snapshots();
}
