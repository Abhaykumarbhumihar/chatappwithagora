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
// AndroidNotificationChannel channel = const AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   importance: Importance.high,
// );
//
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (Platform.isAndroid) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA',
//         appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2',
//         messagingSenderId: '230877096711',
//         projectId: 'firereal-fffc4',
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//
//   print('Handling a background message ${message.messageId}');
// }
//
// void showNotification(RemoteMessage message, {bool isVideoCall = false}) {
//   RemoteNotification? notification = message.notification;
//   AndroidNotification? android = message.notification?.android;
//   var data = message.data;
//
//   flutterLocalNotificationsPlugin.show(
//     notification.hashCode,
//     notification.title,
//     notification.body,
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         channel.id,
//         channel.name,
//         playSound: true,
//         icon: isVideoCall ? "@mipmap/ic_launcher" : "drawable/notiicon_icon",
//       ),
//     ),
//   );
// }
//
// void handleVideoCallNotification(RemoteMessage message) {
//   var videoChannelId = message.data?['channelid'];
//   var name = message.data?['name'];
//   var userId = message.data?['userid'];
//   var imageUrl = message.data?['imageurl'];
//
//   Get.to(CallReceiveScreen(
//     imageUrl: imageUrl,
//     name: name,
//     userId: userId,
//     receivecall: true,
//     channelId: videoChannelId,
//   ));
//
//   showNotification(message, isVideoCall: true);
// }
//
// void handleRegularNotification(RemoteMessage message) {
//   if (Get.isRegistered<IndividualChatController>()) {
//     var myController = Get.find<IndividualChatController>();
//     var chatId = message.data?['custom_key'] ?? "";
//
//     if (!myController.isPageOpen || chatId != myController.chatIdd) {
//       showNotification(message);
//     }
//   } else {
//     var myController = Get.put(IndividualChatController());
//     var chatId = message.data?['custom_key'] ?? "";
//
//     if (!myController.isPageOpen || chatId != myController.chatIdd) {
//       showNotification(message);
//     }
//   }
// }
//
// Future<void> main() async {
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     if (Platform.isAndroid) {
//       await Firebase.initializeApp(
//         options: const FirebaseOptions(
//           apiKey: 'AIzaSyB1F-rdst3N8Zcg03iPfHfZRtIT0Ge-NqA',
//           appId: '1:230877096711:android:4ac7c38d8dc5ceadd9b3a2',
//           messagingSenderId: '230877096711',
//           projectId: 'firereal-fffc4',
//         ),
//       );
//     } else {
//       await Firebase.initializeApp();
//     }
//
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//     final appLifecycleObserver = AppLifecycleObserver();
//     WidgetsBinding.instance.addObserver(appLifecycleObserver);
//
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (message.data?['videocall'] == true) {
//         handleVideoCallNotification(message);
//       } else {
//         showNotification(message,isVideoCall: false);
//       }
//     });
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
//       if (message?.data?['videocall'] == true) {
//         handleVideoCallNotification(message!);
//       } else {
//         handleRegularNotification(message!);
//       }
//     });
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     runApp(ScreenUtilInit(
//       useInheritedMediaQuery: true,
//       builder: (BuildContext context, Widget? child) {
//         return GetMaterialApp(
//           initialBinding: BindingsBuilder(() {
//             Get.put(ProfileController());
//           }),
//           debugShowCheckedModeBanner: false,
//           home: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: SplashScreen(),
//           ),
//         );
//       },
//     ));
//   } catch (err) {
//     print(err);
//   }
// }
