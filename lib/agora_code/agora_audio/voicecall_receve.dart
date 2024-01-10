import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_caht_module/agora_code/agora_audio/voice_call_start.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controllers/individual_chat_controller.dart';

class MakeVoiceCall extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String lname;
  final String receiverid;

  MakeVoiceCall(
      {required this.fname,
        required this.imageUrl,
        required this.userId,
        required this.receivecall,
        required this.channelId,
        required this.lname,
        required this.receiverid});

  @override
  State<MakeVoiceCall> createState() => _MakeVoiceCallState();
}

class _MakeVoiceCallState extends State<MakeVoiceCall> {
  var userToken = "";
  var controller = Get.find<IndividualChatController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDatareceiver(widget.channelId);
    controller.getAudioCallDetails();
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
                  '${widget.imageUrl}', // Replace with your image URL
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              controller.audiocallactiveornotstatus == true
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16.0),
                  const Text(
                    'Incoming Voice Call',
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

                          Get.to(VoiceCallScrenn(
                              imageUrl: widget.imageUrl,
                              fname: widget.fname,
                              userId: widget.userId,
                              receivecall: true,
                              channelId: widget.channelId,
                              agoratoken: userToken,
                              lname: ''));
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


  void fetchDatareceiver(channelName) async {
    // URL and request body
    const String url =
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
}
