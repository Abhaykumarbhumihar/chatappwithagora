// import 'dart:io';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_caht_module/UserInputWidget.dart';
// import 'package:flutter_caht_module/agora_code/makevideocall.dart';
// import 'package:flutter_caht_module/controllers/profilecontroller.dart';
// import 'package:flutter_caht_module/screen/splash_screen.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import 'binding/Binding.dart';
// import 'controllers/individual_chat_controller.dart';
// import 'utils/AppLifecycleObserver.dart';
//
//
// AndroidNotificationChannel channel = const AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   importance: Importance.high,
// );
//
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   if (Platform.isAndroid) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA', // Replace with your actual API key
//         appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2', // Replace with your actual App ID
//         messagingSenderId: '230877096711', // Replace with your actual Messaging Sender ID
//         projectId: 'firereal-fffc4', // Replace with your actual Project ID
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//
//   print('Handling a background message ${message.messageId}');
// }
//
// Future<void> main() async {
//
// try{
//   WidgetsFlutterBinding.ensureInitialized();
//
//
//   if (Platform.isAndroid) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA', // Replace with your actual API key
//         appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2', // Replace with your actual App ID
//         messagingSenderId: '230877096711', // Replace with your actual Messaging Sender ID
//         projectId: 'firereal-fffc4', // Replace with your actual Project ID
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//   final appLifecycleObserver = AppLifecycleObserver();
//   WidgetsBinding.instance.addObserver(appLifecycleObserver);
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print(message);
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     print("SDF SDF SDF SDF DSFDS F");
//     if (notification != null && android != null) {
//       var videocallValue = message?.data['videocall'];
//       if(videocallValue==true){
//         //send video call notification here
//         var    videochannelid = message?.data['channelid'];
//         var    name = message?.data['name'];
//         var    id = message?.data['userid'];
//         var imageUrl=message?.data['imageurl'];
//         print("NOTICICATION CHH  $videochannelid");
//         Get.to(CallReceiveScreen(
//           imageUrl: imageUrl,
//           name: name,
//           userId: id,
//           receivecall: true,
//           channelId: videochannelid,
//         ));
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(channel.id, channel.name,
//                   //channel.description,
//                   color: Colors.transparent,
//                   playSound: true,
//                   icon: "@mipmap/ic_launcher"),
//             ));
//
//         // i want make route from here to VideoCallScreen
//
//       }
//       else{
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 //channel.description,
//                 playSound: true,
//                 icon: "drawable/notiicon_icon",
//               ),
//             ));
//       }
//
// /*TODO-- pass rote here*/
//       // _homepage = TwilioPhoneNumberInput();
//     }
//   });
//   FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
//     RemoteNotification? notification = message?.notification;
//     AndroidNotification? android = message?.notification?.android!;
//     var data = message?.data;
//     if (message?.data != null) {
//
//       if (Get.isRegistered<IndividualChatController>()) {
//         print("MyController is registered.");
//         var videocallValue = message?.data['videocall'];
//         print("MESSAGE DATA IS");
//         print(message?.data);
//         var  myController = Get.find<IndividualChatController>();
//         print("6666666666  ${message?.data['videocall']=="true"}  ${message?.data}");
//         if(videocallValue=="true"){
//
//           //send video call notification here
//           var    videochannelid = message?.data['channelid'];
//           print("NOTICICATION CHH  $videochannelid");
//           Get.to(CallReceiveScreen(
//             imageUrl: "",
//             name: "",
//             userId: "",
//             receivecall: true,
//             channelId: videochannelid,
//           ));
//           flutterLocalNotificationsPlugin.show(
//               notification.hashCode,
//               "${data!['title']}",
//               "${data!['body']}",
//               NotificationDetails(
//                 android: AndroidNotificationDetails(channel.id, channel.name,
//                     //channel.description,
//                     color: Colors.transparent,
//                     playSound: true,
//                     icon: "@mipmap/ic_launcher"),
//               ));
//
//         }else{
//
//           if(myController.isPageOpen==false){
//             flutterLocalNotificationsPlugin.show(
//                 notification.hashCode,
//                 "${data!['title']}",
//                 "${data!['body']}",
//                 NotificationDetails(
//                   android: AndroidNotificationDetails(channel.id, channel.name,
//                       //channel.description,
//                       color: Colors.transparent,
//                       playSound: true,
//                       icon: "@mipmap/ic_launcher"),
//                 ));
//           }
//           else{
//             print("c c c c c c c c c c c c c ");
//             if(data!['custom_key']!=myController.chatIdd){
//               flutterLocalNotificationsPlugin.show(
//                   notification.hashCode,
//                   "${data!['title']}",
//                   "${data!['body']}",
//                   NotificationDetails(
//                     android: AndroidNotificationDetails(channel.id, channel.name,
//                         //channel.description,
//                         color: Colors.transparent,
//                         playSound: true,
//                         icon: "@mipmap/ic_launcher"),
//                   ));
//             }
//           }
//         }
//
//       }
//       else {
//         var videocallValue = message?.data['videocall'];
//         print("MESSAGE DATA IS");
//         print(message?.data);
//         var myController =
//         Get.put(IndividualChatController());
//
//         if(videocallValue=="true"){
//           //send video call notification here
//        var    videochannelid = message?.data['channelid'];
//        print("NOTICICATION CHH  $videochannelid");
//        Get.to(CallReceiveScreen(
//          imageUrl: "",
//          name: "",
//          userId: "",
//          receivecall: true,
//          channelId: videochannelid,
//        ));
//           flutterLocalNotificationsPlugin.show(
//               notification.hashCode,
//               "${data!['title']}",
//               "${data!['body']}",
//               NotificationDetails(
//                 android: AndroidNotificationDetails(channel.id, channel.name,
//                     //channel.description,
//                     color: Colors.transparent,
//                     playSound: true,
//                     icon: "@mipmap/ic_launcher"),
//               ));
//
//         }
//         else{
//           if(myController.isPageOpen==false){
//             flutterLocalNotificationsPlugin.show(
//                 notification.hashCode,
//                 "${data!['title']}",
//                 "${data!['body']}",
//                 NotificationDetails(
//                   android: AndroidNotificationDetails(channel.id, channel.name,
//                       //channel.description,
//                       color: Colors.transparent,
//                       playSound: true,
//                       icon: "@mipmap/ic_launcher"),
//                 ));
//           }else{
//             if(data!['custom_key']!=myController.chatIdd){
//               flutterLocalNotificationsPlugin.show(
//                   notification.hashCode,
//                   "${data!['title']}",
//                   "${data!['body']}",
//                   NotificationDetails(
//                     android: AndroidNotificationDetails(channel.id, channel.name,
//                         //channel.description,
//                         color: Colors.transparent,
//                         playSound: true,
//                         icon: "@mipmap/ic_launcher"),
//                   ));
//             }
//           }
//         }
//
//       }
//
//
//
// /*TODO-- pass rote here*/
//       // _homepage = TwilioPhoneNumberInput();
//     } else {
//       print("COMING IN ERRORR");
//     }
//   });
//
//   /// Create an Android Notification Channel.
//   ///
//   /// We use this channel in the `AndroidManifest.xml` file to override the
//   /// default FCM channel to enable heads up notifications.
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   /// Update the iOS foreground notification presentation options to allow
//   /// heads up notifications.
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   runApp(ScreenUtilInit(
//     useInheritedMediaQuery: true,
//     builder: (BuildContext context, Widget? child) {
//
//
//
//       return GetMaterialApp(
//           initialBinding: BindingsBuilder(() {
//             Get.put(ProfileController());
//           }),
//           debugShowCheckedModeBanner: false,
//           home: MaterialApp(
//               debugShowCheckedModeBanner: false,
//               home: SplashScreen()));
//     },
//   ));
// }catch(err){
//   print(err);
// }
//
//
// }
//
//
//
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caht_module/agora_code/makevideocall.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:flutter_caht_module/screen/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controllers/individual_chat_controller.dart';
import 'utils/AppLifecycleObserver.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA',
        appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2',
        messagingSenderId: '230877096711',
        projectId: 'firereal-fffc4',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  print('Handling a background message ${message.messageId}');
}

void showNotification(RemoteMessage message, {bool isVideoCall = false}) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  var data = message.data;


  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification?.title,
    notification?.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        playSound: true,
        icon: "@mipmap/ic_launcher",

      ),
    ),
  );
}


void handleVideoCallNotification(RemoteMessage message) {
  var videoChannelId = message.data?['channelid'];
  var fname = message.data?['fname'];
  var calleruserId = message.data?['userid'];
  var imageUrl = message.data?['imageurl'];
  var lname = message.data?['lname'];
  var receiverId = message.data?['receiverid'];

  var myController = Get.isRegistered<IndividualChatController>()
      ? Get.find<IndividualChatController>()
      : Get.put(IndividualChatController());

  var userlist = [receiverId, calleruserId]..sort();
  var userJoin = userlist.join('-');
  print("IN NOTIFICATION CALLING STATUS UPDATE  ${userJoin}");

  myController.callringingornot(userJoin);
myController.getCallDetails();
  Get.to(CallReceiveScreen(
    imageUrl: imageUrl,
    fname: fname,
    lname: lname,
    userId: calleruserId,
    receivecall: true,
    channelId: videoChannelId,
    receiverid: receiverId,
  ));

  showNotification(message, isVideoCall: true);
}


void handleRegularNotification(RemoteMessage message) {
  if (Get.isRegistered<IndividualChatController>()) {
    var myController = Get.find<IndividualChatController>();
    var chatId = message.data?['custom_key'] ?? "";

    if (!myController.isPageOpen || chatId != myController.chatIdd) {
      showNotification(message);
    }
  } else {
    var myController = Get.put(IndividualChatController());
    var chatId = message.data?['custom_key'] ?? "";

    if (!myController.isPageOpen || chatId != myController.chatIdd) {
      showNotification(message);
    }
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA',
          appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2',
          messagingSenderId: '230877096711',
          projectId: 'firereal-fffc4',
          storageBucket: "firereal-fffc4.appspot.com",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final appLifecycleObserver = AppLifecycleObserver();
    WidgetsBinding.instance.addObserver(appLifecycleObserver);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data?['videocall'] == "true") {
        handleVideoCallNotification(message);


      } else {
        showNotification(message, isVideoCall: false);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print("NOTIFICATION IS COMMING IN onMessage");
      print(message?.data);
      //  {videocall: true, imageurl: , name: diwalit, body: Video call , title: Video Call,
      //  userid: IPoBtAe97VbyxhqGzpi9G9EHOJw1, channelid: asGFK2IKOeZRd2Ur0mQuFW2Wwvm21704204144055, custom_key: videocall}
      if (message?.data?['videocall'] == "true") {
        handleVideoCallNotification(message!);
      } else {
        handleRegularNotification(message!);
      }
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    runApp(ScreenUtilInit(
      useInheritedMediaQuery: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          initialBinding: BindingsBuilder(() {
            Get.put(ProfileController());
          }),
          debugShowCheckedModeBanner: false,
          home:  MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        );
      },
    ));
  } catch (err) {
    print(err);
  }
}
class DynamicView extends StatefulWidget {
  const DynamicView({super.key});

  @override
  State<DynamicView> createState() => _DynamicViewState();
}



class _DynamicViewState extends State<DynamicView> {
  bool isMyFullScreen = false;
  double _positionX = 0.0;
  double _positionY = 0.0;




  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  isMyFullScreen = !isMyFullScreen;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.greenAccent,
                child: Stack(
                  children: <Widget>[
                    // Your green container content
                    isMyFullScreen
                        ? Container(
                      child: const Center(
                        child: Text(
                          "i am full screen",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    )
                        : Container(
                      child: const Center(
                        child: Text(
                          "i am remote",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    // Draggable container
                    Positioned(
                      left: _positionX,
                      top: _positionY,
                      child: Draggable(
                        // Make the container draggable
                        feedback: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.23,
                          color: Colors.deepPurple.withOpacity(0.5),
                          child: isMyFullScreen
                              ? Container(
                            child: const Center(
                              child: Text(
                                "I am full screen",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                              : Container(
                            child: const Center(
                              child: Text(
                                "I am remote",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Container(),
                        onDraggableCanceled: (Velocity velocity, Offset offset) {
                          // Update the position when dragging is canceled
                          double maxX = MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * 0.5;
                          double maxY = MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.23;

                          double newX = offset.dx.clamp(0.0, maxX);
                          double newY = offset.dy.clamp(0.0, maxY);

                          setState(() {
                            _positionX = newX;
                            _positionY = newY;
                          });
                        },
                        // Make the container draggable
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.23,
                          color: Colors.deepPurple,
                          child: isMyFullScreen
                              ? Container(
                            child: const Center(
                              child: Text(
                                "I am full screen",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                              : Container(
                            child: const Center(
                              child: Text(
                                "I am remote",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}