
import 'package:flutter/cupertino.dart';

class PasswordModel extends ChangeNotifier {
  bool _isObscure = true;
  bool get isObscure => _isObscure;

  toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }
}