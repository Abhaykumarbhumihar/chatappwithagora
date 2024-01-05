import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_caht_module/screen/ProfilePage.dart';
import 'package:flutter_caht_module/screen/login.dart';
import 'package:flutter_caht_module/screen/recentchat.dart';
import 'package:get/get.dart';
import '../collection/fb_collections.dart';
import '../controllers/recentchat_controller.dart';
import '../firebase_services/auth_services.dart';
Future<bool> isUserLoggedIn() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}

class SplashScreen extends StatelessWidget {
  final BaseAuth _auth = Auth();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Name',
      home: AnimatedSplashScreen(
        duration: 3000, // Adjust the duration as needed
        splash: Image.asset('assets/splash_image.png'), // Replace with your splash image
        nextScreen: FutureBuilder<bool>(
          future: isUserLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Add a loading indicator if needed
            } else {
              if (snapshot.data == true) {

                  Map<String, dynamic> userData = {
                    'lastseen':"Online",
                  };
                   FBCollections.users.doc(_auth.getCurrentUser()!.uid).update(userData);//last seen time update on firestor user collection
                var controller=  Get.put(RecentChatController());
                  controller.getData();
                return RecentChat();
              } else {
                return Login();
              }
            }
          },
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white, // Change to your desired background color
      ),
    );
  }
}
