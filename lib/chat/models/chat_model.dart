import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  double _sendingProgress = 0;
  double get sendingProgress => _sendingProgress;

  List<ChatMessageWithData> _messages = [];

  List<ChatMessageWithData> get messages => _messages;

  void _startUpdates() {
    _chatRepository.getChatMessages(_groupChatId).forEach((element) {
      if (element.docs.isNotEmpty) {
        _messages = element.docs
            .map((e) => ChatMessageWithData(
                e.data()[FirebaseConst.idFrom] == _currentUser.uid,
                _mapIntToType(e.data()[FirebaseConst.type]),
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

  Future<bool> sendMessage(dynamic content, int type) async {
    dynamic result = await _chatRepository.sendMessage(
        _groupChatId, _chatId, _currentUser, content, type);
    if (content is File && result is Stream<StorageTaskEvent>) {
      int fileSize = await content.length();
      result.listen((event) {
        double progress = (event.snapshot.bytesTransferred / fileSize);
        log(progress.toString());
        _sendingProgress = progress;
        notifyListeners();
      });
    }
    _sendingProgress = 0;
    return true;
  }

  Future<String> getVideo(String path) {
    return _chatRepository.getVideo(path);
  }

  ChatMessageType _mapIntToType(int value) {
    if (value == ChatMessageType.Text.index) {
      return ChatMessageType.Text;
    } else if (value == ChatMessageType.Map.index) {
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
