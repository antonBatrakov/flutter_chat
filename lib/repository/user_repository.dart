import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Stream<SignInResult> signInWithGoogle() async* {
    yield SignInResult.inProgress;

    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
    await _firebaseAuth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user.isAnonymous) {
      yield SignInResult.failed;
      return;
    }
    if (await user.getIdToken() == null) {
      yield SignInResult.failed;
      return;
    }

    final User currentUser = _firebaseAuth.currentUser;
    if (user.uid != currentUser.uid) {
      yield SignInResult.failed;
      return;
    }

    User firebaseUser =
        (await _firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      _updateUser(firebaseUser);
    } else {
      yield SignInResult.failed;
      return;
    }

    yield SignInResult.success;
  }

  Stream<SignInResult> signInWithCredentials(
      String email, String password) async* {
    yield SignInResult.inProgress;
    UserCredential authResult = await _firebaseAuth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((error) async* {
      log(error);
    });
    User user = authResult.user;
    if (user == null) {
      await signUp(email: email, password: password).then((value) {
        user = value.user;
      }).catchError((error) async* {
        yield SignInResult.failed;
        return;
      });
    }

    if (user != null) {
      _updateUser(user);
    } else {
      yield SignInResult.failed;
      return;
    }
    yield SignInResult.success;
  }

  Future<UserCredential> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  bool isSignedIn() {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  User getUser() {
    return _firebaseAuth.currentUser;
  }

  _updateUser(User firebaseUser) async {
    // Check is already sign up

    if (await _isFirstTimeUser(firebaseUser)) {
      // Update data to server if new user
      FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        'nickname': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
        'id': firebaseUser.uid
      });
    }
  }

  Future<bool> _isFirstTimeUser(User firebaseUser) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length == 0;
  }
}
