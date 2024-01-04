import 'package:flutter/cupertino.dart';

import '../collection/fb_collections.dart';
import '../firebase_services/auth_services.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final BaseAuth _auth = Auth();





  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // The app is going into the background or is being closed.
       /*todo----write here lastseen code*/
      onlinOffline(DateTime.now().millisecondsSinceEpoch.toString());
    }else if(state == AppLifecycleState.resumed){
      onlinOffline("Online");
    }else if(state==AppLifecycleState.inactive){
      onlinOffline(DateTime.now().millisecondsSinceEpoch.toString());
    }else if(state==AppLifecycleState.detached){
      onlinOffline(DateTime.now().millisecondsSinceEpoch.toString());
    }

  }



  void onlinOffline(status)async{
    Map<String, dynamic> userData = {
      'lastseen':status,
    };
    await FBCollections.tokens.doc(_auth.getCurrentUser()!.uid).update(userData);//last seen time update on firestor user collection

  }
}
