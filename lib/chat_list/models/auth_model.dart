import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthModel extends ChangeNotifier {
  final UserRepository _userRepository;

  AuthModel(this._userRepository) {
    _updateStatus(AuthResult.inProgress);

    _updateStatus(
        _userRepository.isSignedIn() ? AuthResult.signedId : AuthResult.none);
  }

  AuthResult _result;

  AuthResult get result => _result;

  signInWithGoogle() {
    try {
      _userRepository.signInWithGoogle().listen((event) {
        _updateStatus(event);
      }, cancelOnError: true).onError((error) {
        Fluttertoast.showToast(
          msg: error.toString(),
          backgroundColor: Colors.grey,
        );
        _updateStatus(AuthResult.failed);
      });
    } catch (exception) {
      Fluttertoast.showToast(
        msg: exception.toString(),
        backgroundColor: Colors.grey,
      );
      log(exception);
      _updateStatus(AuthResult.failed);
    }
  }

  signInWithCredentials(String email, String password) {
    try {
      _updateStatus(AuthResult.inProgress);
      _userRepository.signInWithCredentials(email, password).listen((event) {
        _updateStatus(event);
      }, cancelOnError: true).onError(
          (error) => _updateStatus(AuthResult.failed));
    } catch (exception) {
      log(exception);
      _updateStatus(AuthResult.failed);
    }
  }

  signOut() {
    _userRepository
        .signOut()
        .then((value) => _updateStatus(AuthResult.signedOut))
        .catchError((error) {
      log(error);
      _updateStatus(AuthResult.failed);
    });
  }

  _updateStatus(AuthResult newResult) {
    _result = newResult;
    notifyListeners();
  }
}

enum AuthResult { signedId, signedOut, failed, inProgress, none }
