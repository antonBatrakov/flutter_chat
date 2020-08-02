import 'package:flutter/foundation.dart';

class GroupListSource extends ChangeNotifier {
  List<String> _items = [
    "firstGroup",
    "secondGroup",
    "thirdGroup",
    "forthGroup",
    "fifthGroup",
  ];

  List<String> get items => _items;

  set items(List<String> newChatItems) {
    _items = newChatItems;
    notifyListeners();
  }
}
