import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/repository/chat_repository.dart';
import 'package:flutter_chat/util/firebase_const.dart';

class ChatModel extends ChangeNotifier {
  ChatModel(this._chatRepository, this._chatId) {
    _updateChattingWith();
    _startUpdates();
  }

  String _groupChatId;
  User _currentUser = FirebaseAuth.instance.currentUser;
  ChatRepository _chatRepository;
  String _chatId;

  List<ChatMessageWithData> _messages = [];

  List<ChatMessageWithData> get messages => _messages;

  void _startUpdates() {
    _chatRepository.getChatMessages(_groupChatId).forEach((element) {
      if (element.docs.isNotEmpty) {
        _messages = element.docs
            .map((e) => ChatMessageWithData(
                e.data()[FirebaseConst.idFrom] == _currentUser.uid,
                mapIntToType(e.data()[FirebaseConst.type]),
                e.data()[FirebaseConst.timestamp],
                e.data()[FirebaseConst.content]))
            .toList();
        notifyListeners();
      } else {
        _messages = [];
        notifyListeners();
      }
    });
  }

  void _updateChattingWith() {
    if (_currentUser.uid.hashCode <= _chatId.hashCode) {
      _groupChatId = '${_currentUser.uid}-$_chatId';
    } else {
      _groupChatId = '$_chatId-${_currentUser.uid}';
    }

    _chatRepository.updateChattingWith(_chatId);
  }

  void sendMessage(String content, int type) {
    var documentReference = FirebaseFirestore.instance
        .collection(FirebaseConst.messages)
        .doc(_groupChatId)
        .collection(_groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          FirebaseConst.idFrom: _currentUser.uid,
          FirebaseConst.idTo: _chatId,
          FirebaseConst.timestamp:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirebaseConst.content: content,
          FirebaseConst.type: type
        },
      );
    });
  }

  ChatMessageType mapIntToType(int value) {
    if (value == 0) {
      return ChatMessageType.Text;
    } else if (value == 1) {
      return ChatMessageType.Map;
    } else {
      return ChatMessageType.Video;
    }
  }
}

class ChatMessageWithData {
  ChatMessageWithData(
      this.isFromCurrentUser, this.type, this.timeStamp, this.content);

  final bool isFromCurrentUser;
  final ChatMessageType type;
  final String timeStamp;
  final dynamic content;
}

enum ChatMessageType { Text, Map, Video }
