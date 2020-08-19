import 'dart:async';

import 'package:built_value/built_value.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/util/firebase_const.dart';

class ChatListSource extends ChangeNotifier {
  ChatListSource() {
    _streamController.sink.add(List<Chat>(0));
    fetchItems();
  }

  StreamController _streamController = StreamController<List<Chat>>();

  Stream<List<Chat>> get items => _streamController.stream;

  fetchItems() {
    FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .snapshots()
        .forEach((element) {
      if (element == null || element.docs.isEmpty) {
        _streamController.sink.add(List<Chat>(0));
      } else {
        _streamController.sink.add(element.docs
            .where((element) =>
                element.data()[FirebaseConst.nickname] !=
                    FirebaseAuth.instance.currentUser.displayName &&
                element.data()[FirebaseConst.nickname] !=
                    FirebaseAuth.instance.currentUser.email)
            .map((e) {
          return Chat(
              e.data()[FirebaseConst.nickname], e.data()[FirebaseConst.photoUrl], e.data()[FirebaseConst.id]);
        }).toList());
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    _streamController.close();
  }
}

class Chat {
  Chat(this.nickname, this.photoUrl, this.id);

  final String nickname;
  @nullable
  final String photoUrl;
  final String id;
}
