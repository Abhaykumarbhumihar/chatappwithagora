import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_caht_module/agora_code/videocall_pojo.dart';
import 'package:flutter_caht_module/screen/recentchat.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import '../collection/fb_collections.dart';
import '../controllers/individual_chat_controller.dart';
import '../controllers/profilecontroller.dart';
import '../controllers/recentchat_controller.dart';
import '../firebase_services/auth_services.dart';

const String appId = "ab0e65d266354bf684b91530ee7e481a";
//const String appId = "66389225174d4459a2338888c17a6537";

class VideoCallScreen extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String agoratoken;
  final String lname;

  VideoCallScreen(
      {required this.fname,
      required this.imageUrl,
      required this.userId,
      required this.receivecall,
      required this.channelId,
      required this.agoratoken,
      required this.lname});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  ///call duration
  late Timer _callDurationTimer;
  int _callDurationInSeconds = 0;

  String get formattedCallDuration {
    // Convert seconds to HH:mm:ss format
    int hours = _callDurationInSeconds ~/ 3600;
    int minutes = (_callDurationInSeconds % 3600) ~/ 60;
    int seconds = _callDurationInSeconds % 60;
    String formattedTime = '';

    if (hours > 0) {
      formattedTime += '$hours:';
    }

    formattedTime += '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  late StreamSubscription<QuerySnapshot> callStreamSubscription;
  int volume = 50;
  bool isccallstart = false;
  bool _isScreenShared = false;
  bool _isCalldisconnet = false;

  ///jb meeting se sare user left ho jayenge means ab only local user hai
  final BaseAuth _auth = Auth();
  bool _isMuted = false;
  bool _isFrontCamera = true; // Indicates if the local user is muted
  bool _isCameraOn = true;
  Map<int, bool> remoteUserMuteStates = {};
  Map<int, bool> remoteUserMuteVideoStates = {};

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  List<int> _remoteUids = [];
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  bool isFullScreen = false;
  bool myfullscreen = false;
  bool remotefullscreen = true;

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> shareScreen() async {
    setState(() {
      _isScreenShared = !_isScreenShared;
    });

    if (_isScreenShared) {
      // Start screen sharing
      agoraEngine.startScreenCapture(const ScreenCaptureParameters2(
          captureAudio: true,
          audioParams: ScreenAudioParameters(
              sampleRate: 16000, channels: 2, captureSignalVolume: 100),
          captureVideo: true,
          videoParams: ScreenVideoParameters(
              dimensions: VideoDimensions(height: 1280, width: 720),
              frameRate: 15,
              bitrate: 600)));
    } else {
      await agoraEngine.stopScreenCapture();
    }

    // Update channel media options to publish camera or screen capture streams
    ChannelMediaOptions options = ChannelMediaOptions(
      publishCameraTrack: !_isScreenShared,
      publishMicrophoneTrack: !_isScreenShared,
      publishScreenTrack: _isScreenShared,
      publishScreenCaptureAudio: _isScreenShared,
      publishScreenCaptureVideo: _isScreenShared,
    );

    agoraEngine.updateChannelMediaOptions(options);
  }

  bool isContainerAInFullPage = true;
  var callactiveornotstatus;
  var callringingornotstatus = '';

  ///this is for draggable view
  bool isMyFullScreen = true;
  double _positionX = 0.0;
  double _positionY = 0.0;

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
    getCallDetails();
  }

// Build UI
  @override
  Widget build(BuildContext context) {
    getCallDetails();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            SizedBox(
              width: Get.width,
              height: Get.height,
              child: _remoteUids.length > 1
                  ? _buildRemoteVideoGrid()
                  : _remoteVideo(),
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.width * 0.2,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    // Adjust the radius as needed
                    border: Border.all(
                      color: Colors.black, // Set border color as needed
                      width: 3.0, // Set border width as needed
                    ),
                  ),
                  child: _localPreview(),
                )),
            Align(
              alignment: Alignment.topCenter,
              //alignment: Alignment.bottomCenter,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: <Widget>[
                      if (callactiveornotstatus == true)
                        Center(
                          child: Center(
                              child: Text(
                            isccallstart
                                ? "" // Show empty string when isccallstart is true
                                : (callringingornotstatus == "calling"
                                    ? "Calling"
                                    : "Ringing"),
                            style:
                                const TextStyle(color: Colors.black, fontSize: 24.0),
                          )),
                        ),
                      if (callactiveornotstatus == false)
                        const Center(
                            child: Text(
                          "Calling Disconnect",
                          style: TextStyle(color: Colors.black, fontSize: 24.0),
                        )),

                      if (_callDurationInSeconds > 0)
                      const Text(
                        "Call Duration",
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                      if (_callDurationInSeconds > 0)
                        Text(
                          formattedCallDuration,
                          style: const TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                    ],
                  ),
                ),
              ),
            ),


            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        // Set the background color of the CircleAvatar
                        radius: 24.0,
                        // Set the radius of the CircleAvatar
                        child: Center(
                          child: IconButton(
                            splashColor: Colors.white60,
                            iconSize: 20.0,
                            padding: const EdgeInsets.all(8.0),
                            icon: Icon(
                              _isMuted ? Icons.mic_off_rounded : Icons.mic,
                              color: Colors.black,
                              size: 28.0,
                            ),
                            // Specify the icon
                            onPressed: _isJoined ? () => toggleMute() : null,
                          ),
                        ),
                      ),

                      ///camera off on
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        // Set the background color of the CircleAvatar
                        radius: 24.0,
                        // Set the radius of the CircleAvatar
                        child: Center(
                          child: IconButton(
                            splashColor: Colors.white60,
                            iconSize: 20.0,
                            padding: const EdgeInsets.all(8.0),
                            icon: Icon(
                              //_isCameraOn ? "Turn Off Camera" : "Turn On Camera"
                              _isCameraOn ? Icons.videocam : Icons.videocam_off,
                              color: Colors.black,
                              size: 28.0,
                            ),
                            // Specify the icon
                            onPressed: _isJoined ? () => toggleCamera() : null,
                          ),
                        ),
                      ),

                      ///cut call
                      IconButton(
                        splashColor: Colors.white,
                        iconSize: 36.0,
                        padding: const EdgeInsets.all(8.0),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 44.0,
                        ),
                        // Specify the icon
                        onPressed: () {
                          // Action to be performed when the button is pressed
                          leave();
                          print('IconButton pressed!');
                        },
                      ),

                      /// switch camera
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        // Set the background color of the CircleAvatar
                        radius: 24.0,
                        // Set the radius of the CircleAvatar
                        child: Center(
                          child: IconButton(
                            splashColor: Colors.white60,
                            iconSize: 20.0,
                            padding: const EdgeInsets.all(8.0),
                            icon: Icon(
                              //_isCameraOn ? "Turn Off Camera" : "Turn On Camera"
                              _isFrontCamera
                                  ? Icons.cameraswitch_rounded
                                  : Icons.cameraswitch_outlined,
                              color: Colors.black,
                              size: 28.0,
                            ),
                            // Specify the icon
                            onPressed:
                                _isJoined ? () => toggleCameraRotation() : null,
                          ),
                        ),
                      ),

                      /// share screen
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        // Set the background color of the CircleAvatar
                        radius: 24.0,
                        // Set the radius of the CircleAvatar
                        child: Center(
                          child: IconButton(
                            splashColor: Colors.white60,
                            iconSize: 20.0,
                            padding: const EdgeInsets.all(8.0),
                            icon: Icon(
                              //_isCameraOn ? "Turn Off Camera" : "Turn On Camera"
                              _isScreenShared
                                  ? Icons.mobile_off_sharp
                                  : Icons.mobile_screen_share_sharp,
                              color: Colors.black,
                              size: 28.0,
                            ),
                            // Specify the icon

                            onPressed: _isJoined ? () => {shareScreen()} : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      //  Expanded(
                      //    child: ElevatedButton(
                      //      onPressed: _isJoined ? () => leave() : null,
                      //      child: con̵st Text("Leave"),
                      //    ),
                      //  ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _localPreview() {
    // Display local video or screen sharing preview
    if (_isJoined) {
      if (!_isScreenShared) {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agoraEngine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      } else {
        return AgoraVideoView(
            controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: const VideoCanvas(
            cropArea: Rectangle(x: 200, y: 200),
            uid: 0,
            sourceType: VideoSourceType.videoSourceScreen,
          ),
        ));
      }
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            if (callactiveornotstatus == true)
              Center(
                child: Center(
                    child: Text(
                  callringingornotstatus == "calling" ? "Calling" : "Ringing",
                  style: const TextStyle(color: Colors.black, fontSize: 24.0),
                )),
              ),
            if (callactiveornotstatus == false)
              const Center(
                  child: Text(
                "Calling Disconnect",
                style: TextStyle(color: Colors.black, fontSize: 24.0),
              )),
          ],
        ),
      );
    }
  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    agoraEngine.muteLocalAudioStream(_isMuted);
  }

  void toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });

    if (_isCameraOn) {
      agoraEngine.enableVideo();
    } else {
      agoraEngine.disableVideo();
    }
  }

  void toggleCameraRotation() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    agoraEngine.switchCamera();
  }

  Widget _buildRemoteVideoGrid() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: _remoteUids.length,
        itemBuilder: (context, index) {
          int remoteUid = _remoteUids[index];

          print("REMOTE MUTEE\n\n");
          print(remoteUserMuteStates[remoteUid]);
          print("REMOTE MUTEE\n\n");
          bool isRemoteUserMuted = remoteUserMuteStates[remoteUid] ?? false;
          bool isRemoteUserVideoMuted =
              remoteUserMuteVideoStates[remoteUid] ?? false;
          // Check if the remote user is muted by checking if audio is being sent
          //bool isRemoteUserMuted = !_isRemoteAudioActive(remoteUid);

          return InkWell(
            onTap: () {},
            child: Container(
              width: 200,
              height: 250,
              child: Stack(
                children: [
                  AgoraVideoView(
                    controller: VideoViewController.remote(
                      useAndroidSurfaceView: false,
                      useFlutterTexture: false,
                      rtcEngine: agoraEngine,
                      canvas: VideoCanvas(uid: remoteUid),
                      connection: RtcConnection(channelId: widget.channelId),
                    ),
                  ),
                  // Align(child:  Icon(Icons.mic_off, color: Colors.red,size: 24.0),),

                  if (isRemoteUserMuted)
                    const Align(
                      child: Icon(Icons.mic_off, color: Colors.red, size: 24.0),
                    ),

                  if (isRemoteUserVideoMuted)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.videocam_off, color: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Display remote user's video
  Widget _remoteVideo() {
    bool isRemoteUserMuted = remoteUserMuteStates[_remoteUid] ?? false;
    bool isRemoteUserVideoMuted =
        remoteUserMuteVideoStates[_remoteUid] ?? false;
    if (_remoteUid != null) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isMyFullScreen = !isMyFullScreen;
          });
        },
        child: Stack(
          children: [
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: agoraEngine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelId),
              ),
            ),
            if (isRemoteUserMuted)
              const Align(
                child: Icon(Icons.mic_off, color: Colors.red, size: 24.0),
              ),

            if (isRemoteUserVideoMuted)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.videocam_off, color: Colors.red),
              ),
          ],
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication));

    await agoraEngine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
      ),
    );
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    await [Permission.microphone, Permission.camera].request();
    await agoraEngine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await agoraEngine
        .setClientRole(role: ClientRoleType.clientRoleBroadcaster)
        .onError((error, stackTrace) => debugPrint("error $error"));
    await agoraEngine.startPreview(
        sourceType: VideoSourceType.videoSourceRemote);

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            showMessage(
                "Local user uid:${connection.localUid} joined the channel");
            setState(() {
              _isJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            showMessage("Remote user uid:$remoteUid joined the channel");
            setState(() {
              isccallstart = true;
              _remoteUid = remoteUid;
              _remoteUids.add(remoteUid);
              _callDurationTimer =
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                setState(() {
                  _callDurationInSeconds++;
                });
              });
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            showMessage("Remote user uid:$remoteUid left the channel ");
            setState(() {
              _remoteUid = null;
              _remoteUids.remove(remoteUid);
              if (_remoteUids.isEmpty) {
                _callDurationTimer.cancel();
                _isCalldisconnet = false;

                ///means ab meeting me koi bhi remote user nhi hai
                // leave();
                // var controller = Get.put(RecentChatController());
                // controller.getData();
                // Get.off(() => RecentChat());
              }
            });
          },
          onUserMuteAudio:
              (RtcConnection connection, int remoteUid, bool muted) {
            setState(() {
              remoteUserMuteStates[remoteUid] = muted; // True if muted
            });
          },
          onUserMuteVideo:
              (RtcConnection connection, int remoteUid, bool muted) {
            setState(() {
              remoteUserMuteVideoStates[remoteUid] = muted; // True if muted
            });
          },
          onVideoSizeChanged: (RtcConnection connection,
              VideoSourceType sourceType,
              int uid,
              int width,
              int height,
              int rotation) {
            print("SHARING ONNNNNNNN\n\n");
            print(sourceType);
            print("SHARING ONNNNNNNN\n\n");
          },
          onRemoteVideoStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) {}),
    );

    join();
    //
  }

  void join() async {
    print("AGORA TOKEN  ${widget.channelId}");
    print(widget.agoratoken);
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: widget.agoratoken,
      channelId: widget.channelId,
      options: options,
      uid: uid,
    );
  }

  void leave() async {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
      _remoteUids.clear();
    });
    agoraEngine.leaveChannel();
    var userlist = [_auth.getCurrentUser()?.uid, widget.userId]..sort();
    var userJoin = userlist.join('-');
    Map<String, dynamic> userData = {
      'activecall': false,
      'calldisconnectby': _auth.getCurrentUser()!.uid
    };

    await FBCollections.videocall.doc(userJoin).update(userData);
    var controller = Get.isRegistered<RecentChatController>()
        ? Get.find<RecentChatController>()
        : Get.put(RecentChatController());
    controller.getData();
    Get.off(() => RecentChat());
  }

  // Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  Future<void> getCallDetails() async {
    if (Get.find<ProfileController>() == null) {
      Get.put(ProfileController());
    }
    String userId = Get.find<ProfileController>().usermodel.value.id!;
    var chatsCollection = FirebaseFirestore.instance
        .collection('Videocall')
        .where('commonusers', arrayContains: userId)
        .where('activecall', isEqualTo: true);
    Stream<QuerySnapshot> chatStream = chatsCollection.snapshots();
    chatStream.listen((QuerySnapshot chatQuerySnapshot) {
      if (chatQuerySnapshot.docs.isEmpty) {
        // No documents found
        print("No active calls found");
        setState(() {
          callactiveornotstatus = false;
          callringingornotstatus = "SDF SDF ";
          leave();
        });
      } else {
        for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
          Map<String, dynamic> chatData =
              document.data() as Map<String, dynamic>;
          VideoCallData videoCallData = VideoCallData.fromMap(chatData);
          print("CALL STATUS RUNNING");
          print("======= ========" + videoCallData.channelId);
          print(videoCallData.receiverfname);
          print(videoCallData.senderName);
          print("======= ======== ${videoCallData.activeCall}");
          print("======= ======== ${videoCallData.callingstatus}");

          //
          setState(() {
            callactiveornotstatus = videoCallData.activeCall;
            callringingornotstatus = videoCallData.callingstatus + " check";
          });

          //_callactiveornotstatus(videoCallData.activeCall);
          //_callringingornotstatus(videoCallData.callingstatus);
          //update();
        }
      }
    });
  }
}
