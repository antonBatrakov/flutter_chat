import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat/repository/user_repository.dart';

class SignInModel extends ChangeNotifier {
  final UserRepository _userRepository;

  SignInModel(this._userRepository) {
    _updateStatus(SignInResult.inProgress);

    _updateStatus(_userRepository.isSignedIn()
        ? SignInResult.success
        : SignInResult.none);
  }

  SignInResult _result;

  SignInResult get result => _result;

  signInWithGoogle() {
    try {
      _userRepository.signInWithGoogle().listen((event) {
        _updateStatus(event);
      }, cancelOnError: true).onError(
          (error) => _updateStatus(SignInResult.failed));
    } catch (exception) {
      log(exception);
      _updateStatus(SignInResult.failed);
    }
  }

  signInWithCredentials(String email, String password) {
    try {
      _updateStatus(SignInResult.inProgress);
      _userRepository.signInWithCredentials(email, password).listen((event) {
        _updateStatus(event);
      }, cancelOnError: true).onError(
          (error) => _updateStatus(SignInResult.failed));
    } catch (exception) {
      log(exception);
      _updateStatus(SignInResult.failed);
    }
  }

  _updateStatus(SignInResult newResult) {
    _result = newResult;
    notifyListeners();
  }
}

class SignOutModel extends ChangeNotifier {
  SignOutModel(this._userRepository);

  final UserRepository _userRepository;

  SignOutResult _result = SignOutResult.none;

  SignOutResult get result => _result;

  signOut() {
    _userRepository
        .signOut()
        .then((value) => _updateStatus(SignOutResult.success))
        .catchError((error) {
      log(error);
      _updateStatus(SignOutResult.failed);
    });
  }

  _updateStatus(SignOutResult newResult) {
    _result = newResult;
    notifyListeners();
  }
}

enum SignInResult { success, failed, inProgress, none }
enum SignOutResult { success, failed, none }
