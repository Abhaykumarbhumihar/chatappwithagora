import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caht_module/collection/fb_collections.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:flutter_caht_module/firebase_services/auth_services.dart';
import 'package:flutter_caht_module/screen/ProfilePage.dart';
import 'package:flutter_caht_module/screen/splash_screen.dart';
import 'package:flutter_caht_module/utils/CommonDialog.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class LoginController extends GetxController {
  final BaseAuth _auth = Auth();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var loginFormGlobalKey = GlobalKey<FormState>();
  final _termvalue = false.obs;

  bool get termValue => _termvalue.value;

  set termValue(bool flag) {
    _termvalue.value = flag;
    update();
  }






  creatNewUser({BuildContext? context, fNmae, lName, email, pass}) async {
    try {
      var user = await _auth.createUserWithEmailPassword(email, pass);
      if (user != null) {
        Map<String, dynamic> userData = {
          'fname': '$fNmae',
          'lanme': "$lName",
          'email': "$email",
          'password': "$pass",
          'id':user.uid,
        };
        await FBCollections.users.doc(user.uid).set(userData);
        saveToken(user.uid);
        CommonDialog.hideLoading();
        CommonDialog.showsnackbar(
            "Email verification link has been sent to you email");
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      CommonDialog.hideLoading();
    }
  }

  loginUser({BuildContext? context, email, password}) async {
    var user = await _auth.signInWithEmailPassword(email, password);

    if (user != null) {
      print(user);
      saveToken(user.uid);
     var controller= Get.put(ProfileController());
      controller.getUserProfile();
      Get.to(() => ProfilePage());
      //CommonDialog.hideLoading();
    }
  }

  resetPassword(String email) async {
    try {
      await _auth.sendResetPassEmail(email);
      CommonDialog.showsnackbar(
          "Password changing link sent to your email address. kindly verify your account.");
    } catch (e) {
      print(e);
    }
  }


  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }

  saveToken(userId)async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    Map<String, dynamic> userData = {
      'token': '$token',
      'id':'$userId',
      'lastseen':'Online'
    };
    await FBCollections.tokens.doc(userId).set(userData);
  }
}
