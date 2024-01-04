import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_caht_module/utils/CommonDialog.dart';

import '../collection/fb_collections.dart';

abstract class BaseAuth {
  Future<User?> signInWithEmailPassword(String? email, String? password);

  Future<User?> createUserWithEmailPassword(String? email, String? password);

  User? getCurrentUser();

 Future<dynamic> getUserData(String? uid);
  Future<void> signOut();

  Future<void> sendResetPassEmail(String? email);
//Future<void> updateProfile(UserModel? userModel, String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> createUserWithEmailPassword(
      String? email, String? password) async {
    try {
      var user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email!, password: password!))
          .user;
      try {
        await user?.sendEmailVerification();
        return user;
      } catch (e) {
        CommonDialog.showsnackbar(
            "An error occurred while trying to send email  verification");
      }
    } catch (e) {
      return null;
    }
  }

  @override
  User? getCurrentUser() {
    var user = _firebaseAuth.currentUser;
    return user;
  }

  @override
  Future<void> sendResetPassEmail(String? email) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: '$email').then((value) {
      log("success");
    }).catchError((e) {
      String error = e.toString();
      log(error);

      if (error.contains('user-not-found')) {
        CommonDialog.showsnackbar('Email not registered');
      } else {
        log(e.toString());
        CommonDialog.showsnackbar(e.toString());
      }
    });
  }

  @override
  Future<User?> signInWithEmailPassword(String? email, String? password) async {
    try {
      var user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email!, password: password!))
          .user;
      print(user);
      if (user!.emailVerified) {
        return user;
      } else {
        CommonDialog.hideLoading();
        CommonDialog.showsnackbar(
            "You haven't verified your email yet, the link has been sent again to your registered email");
        user.sendEmailVerification();
        FirebaseAuth.instance.signOut();
      }
    } catch (e) {}
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future getUserData(String? uid)async {
    DocumentSnapshot result = await FBCollections.users.doc(uid).get();

    log(result.id);
    return result;
  }
}
