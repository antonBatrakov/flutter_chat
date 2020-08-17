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

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult =
    await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    if (user.isAnonymous) {
      yield SignInResult.failed;
      return;
    }
    if (await user.getIdToken() == null) {
      yield SignInResult.failed;
      return;
    }

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    if (user.uid != currentUser.uid) {
      yield SignInResult.failed;
      return;
    }

    FirebaseUser firebaseUser =
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
    AuthResult authResult = await _firebaseAuth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((error) async* {
      log(error);
    });
    FirebaseUser user = authResult.user;
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

  Future<AuthResult> signUp({String email, String password}) async {
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

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {
    return (await _firebaseAuth.currentUser());
  }

  _updateUser(FirebaseUser firebaseUser) async {
    // Check is already sign up

    if (await _isFirstTimeUser(firebaseUser)) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({
        'nickname': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoUrl,
        'id': firebaseUser.uid
      });
    }
  }

  Future<bool> _isFirstTimeUser(FirebaseUser firebaseUser) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 0;
  }
}
