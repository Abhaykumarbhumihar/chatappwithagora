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
import 'package:flutter_caht_module/screen/recentchat.dart';
import 'package:story_view/story_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caht_module/agora_code/makevideocall.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:flutter_caht_module/screen/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'agora_code/agora_audio/voicecall_receve.dart';
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
  if (kIsWeb) {
    print("I AM HERE FIREBAE");
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDi6oXaQ4k5jNnRxpY5L4Ork5kpAmuoJxE",
          authDomain: "firereal-fffc4.firebaseapp.com",
          databaseURL: "https://firereal-fffc4.firebaseio.com",
          projectId: "firereal-fffc4",
          storageBucket: "firereal-fffc4.appspot.com",
          messagingSenderId: "230877096711",
          appId: "1:230877096711:web:adeb6cc332a37114d9b3a2"),
    );
  } else {
    print("I NOT   AM HERE FIREBAE");
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA',
          appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2',
          messagingSenderId: '230877096711',
          projectId: 'firereal-fffc4',
        ),
      );
    } else if (Platform.isIOS) {
      await Firebase.initializeApp();
    }
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
  var isvideocall = message.data?['videocall'];
  var isaudiocall = message.data?['voicecall'];





  if (isvideocall=="true") {
    myController.callringingornot(
      userJoin,
    );
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
  } else if (isaudiocall=="true") {
    myController.audiocallringingornot(
      userJoin,
    );
    myController.getAudioCallDetails();
    Get.to(MakeVoiceCall(
      imageUrl: imageUrl,
      fname: fname,
      lname: lname,
      userId: calleruserId,
      receivecall: true,
      channelId: videoChannelId,
      receiverid: receiverId,
    ));
  }

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

    if (kIsWeb) {
      print("I AM HERE FIREBAE");
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDi6oXaQ4k5jNnRxpY5L4Ork5kpAmuoJxE",
            authDomain: "firereal-fffc4.firebaseapp.com",
            databaseURL: "https://firereal-fffc4.firebaseio.com",
            projectId: "firereal-fffc4",
            storageBucket: "firereal-fffc4.appspot.com",
            messagingSenderId: "230877096711",
            appId: "1:230877096711:web:adeb6cc332a37114d9b3a2"),
      );
    } else {
      print("I NOT   AM HERE FIREBAE");
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
      } else if (Platform.isIOS) {
        await Firebase.initializeApp();
      }
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final appLifecycleObserver = AppLifecycleObserver();
    WidgetsBinding.instance.addObserver(appLifecycleObserver);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("NOTIFICATION in webbbbb IS COMMING IN onMessage");
      if (message.data?['videocall']=="true" ||
          message.data?['voicecall']=="true" ) {
        handleVideoCallNotification(message);
      } else {
        showNotification(message, isVideoCall: false);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print("NOTIFICATION in webbbbb IS COMMING IN onMessage");
      print(message?.data);
      //  {videocall: true, imageurl: , name: diwalit, body: Video call , title: Video Call,
      //  userid: IPoBtAe97VbyxhqGzpi9G9EHOJw1, channelid: asGFK2IKOeZRd2Ur0mQuFW2Wwvm21704204144055, custom_key: videocall}
      if (message?.data?['videocall'] == "true" ||
          message?.data?['voicecall'] == "true") {
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
          home: MaterialApp(
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
                        onDraggableCanceled:
                            (Velocity velocity, Offset offset) {
                          // Update the position when dragging is canceled
                          double maxX = MediaQuery.of(context).size.width -
                              MediaQuery.of(context).size.width * 0.5;
                          double maxY = MediaQuery.of(context).size.height -
                              MediaQuery.of(context).size.height * 0.23;

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoryListScreen(),
    );
  }
}

class StoryListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> apiResponse = [
    {
      "name": "Abhay",
      "id": 1,
      "status_images": [
        {
          "status_seen": false,
          "image": "https://picsum.photos/213",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/212",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/210",
        }
      ]
    },
    {
      "name": "Rai",
      "id": 2,
      "status_images": [
        {
          "status_seen": true,
          "image": "https://picsum.photos/203",
        },
        {
          "status_seen": true,
          "image": "https://picsum.photos/202",
        },
      ]
    },
    {
      "name": "Abhay",
      "id": 1,
      "status_images": [
        {
          "status_seen": false,
          "image": "https://picsum.photos/213",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/212",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/210",
        }
      ]
    },
    {
      "name": "Rai",
      "id": 2,
      "status_images": [
        {
          "status_seen": true,
          "image": "https://picsum.photos/203",
        },
        {
          "status_seen": true,
          "image": "https://picsum.photos/202",
        },
      ]
    },
    {
      "name": "Abhay",
      "id": 1,
      "status_images": [
        {
          "status_seen": false,
          "image": "https://picsum.photos/213",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/212",
        },
        {
          "status_seen": false,
          "image": "https://picsum.photos/210",
        }
      ]
    },
    {
      "name": "Rai",
      "id": 2,
      "status_images": [
        {
          "status_seen": true,
          "image": "https://picsum.photos/203",
        },
        {
          "status_seen": true,
          "image": "https://picsum.photos/202",
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story List'),
      ),
      body: ListView.builder(
        itemCount: apiResponse.length,
        itemBuilder: (context, index) {
          final user = apiResponse[index];
          return ListTile(
            title: Text(user['name']),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['status_images'].last['image']),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryViewScreen(
                    users: apiResponse,
                    initialUserIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StoryViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final int initialUserIndex;

  StoryViewScreen({
    required this.users,
    required this.initialUserIndex,
  });

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}


class _StoryViewScreenState extends State<StoryViewScreen> {
  final controller = StoryController();
  int currentUserIndex = 0;
  int currentStatusIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.users[currentUserIndex]['name']}\'s Story'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: currentStatusIndex / widget.users[currentUserIndex]['status_images'].length,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.users[currentUserIndex]['status_images'][currentStatusIndex]['status_seen']
                  ? Colors.grey
                  : Colors.green,
            ),
            backgroundColor: Colors.grey,
          ),
          Expanded(
            child: StoryView(
              controller: controller,
              storyItems: widget.users[currentUserIndex]['status_images']
                  .map<StoryItem>((statusImage) => StoryItem.pageImage(
                url: statusImage['image'],
                controller: controller,
                duration: const Duration(seconds: 5),
              ))
                  .toList(),
              onComplete: () {
                // Move to the next user if all status images of the current user are shown
                int nextStatusIndex = currentStatusIndex + 1;
                if (nextStatusIndex < widget.users[currentUserIndex]['status_images'].length) {
                  setState(() {
                    currentStatusIndex = nextStatusIndex;
                    controller.play();
                  });
                } else {
                  int nextUserIndex = currentUserIndex + 1;
                  if (nextUserIndex < widget.users.length) {
                    setState(() {
                      currentUserIndex = nextUserIndex;
                      currentStatusIndex = 0; // Reset status index for the next user
                    });
                    controller.play();
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  // Navigate back when swiped down
                  Navigator.pop(context);
                }
              },
              onStoryShow: (storyItem) {
                // Update progress indicator when a new story is shown
                int index = widget.users[currentUserIndex]['status_images']
                    .indexWhere((element) => element == storyItem.view);
                if (index != -1) {
                  setState(() {
                    currentStatusIndex = index;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}