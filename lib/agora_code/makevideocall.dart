import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_caht_module/agora_code/video_call_start.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caht_module/agora_code/videocall_pojo.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../collection/fb_collections.dart';
import '../controllers/individual_chat_controller.dart';
import '../controllers/profilecontroller.dart';
import '../firebase_services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallReceiveScreen extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String lname;
  final String receiverid;

  CallReceiveScreen(
      {required this.fname,
      required this.imageUrl,
      required this.userId,
      required this.receivecall,
      required this.channelId,
      required this.lname,
      required this.receiverid});

  @override
  State<CallReceiveScreen> createState() => _CallReceiveScreenState();
}

class _CallReceiveScreenState extends State<CallReceiveScreen> {
  var userToken = "";
  var controller = Get.find<IndividualChatController>();

  void fetchDatareceiver(channelName) async {
    // URL and request body
    final String url =
        'https://api.vegansmeetdaily.com/api/v1/users/create_agora_token';
    final Map<String, String> body = {
      'channel_name': channelName,
      'appId': 'ab0e65d266354bf684b91530ee7e481a',
      'appCertificate': '1aef02116e3c474d97cc6fbf6c8086a9',
    };

    // Make the HTTP POST request
    final response = await http.post(Uri.parse(url), body: body);

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Access the data field
      String token = responseData['data'];
      setState(() {
        userToken = responseData['data'];
      });

      // Handle the token as needed
      print('Token: $token');
    } else {
      // Handle errors
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDatareceiver(widget.channelId);
    controller.getCallDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: GetBuilder<IndividualChatController>(builder: (controller) {
        return
          Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              //  '${widget.imageUrl}', // Replace with your image URL
              'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            controller.callactiveornotstatus == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16.0),
                      const Text(
                        'Incoming Video Call',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${widget.fname} ${widget.lname}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.call_end,
                              color: Colors.red,
                              size: 40.0,
                            ),
                            onPressed: () {
                              var userlist = [widget.receiverid, widget.userId]
                                ..sort();
                              var userJoin = userlist.join('-');
                              print(
                                  "AT DISCONNECT CALLING STATEUS ${userJoin}");
                              var myController =
                                  Get.isRegistered<IndividualChatController>()
                                      ? Get.find<IndividualChatController>()
                                      : Get.put(IndividualChatController());
                              myController.leaveDisconnectCall(userJoin,context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.call,
                              color: Colors.green,
                              size: 40.0,
                            ),
                            onPressed: () {
                              // Add logic for accepting the call
                              print("GETTNG CHANNEL ID IS ${widget.channelId}");
                              print(
                                  "GETTING TOKEN WITH CHANNER ${widget.channelId} and token is ${userToken}");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoCallScreen(
                                        imageUrl: widget.imageUrl,
                                        fname: widget.fname,
                                        userId: widget.userId,
                                        receivecall: true,
                                        channelId: widget.channelId,
                                        agoratoken: userToken,
                                        lname: '')),
                              );
                              print('Call Accepted');
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "Call disconnect",
                      style: TextStyle(color: Colors.black, fontSize: 12.0),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        );
      }),
    ));
  }
}
