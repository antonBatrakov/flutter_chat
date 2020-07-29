import 'package:flutter/foundation.dart';

class ChatListSource extends ChangeNotifier {
  List<String> _items = ["first", "second", "third", "forth", "fifth"];

  List<String> get items => _items;

  set items( List<String> newChatItems) {
    _items = newChatItems;
    notifyListeners();
  }
}