import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = "ab0e65d266354bf684b91530ee7e481a";

class VoiceCallScrenn extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String agoratoken;
  final String lname;

  VoiceCallScrenn(
      {required this.fname,
      required this.imageUrl,
      required this.userId,
      required this.receivecall,
      required this.channelId,
      required this.agoratoken,
      required this.lname});

  @override
  State<VoiceCallScrenn> createState() => _VoiceCallScrennState();
}

class _VoiceCallScrennState extends State<VoiceCallScrenn> {
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

  bool _isCalldisconnet = false;

  late RtcEngine agoraEngine;
  bool _isJoined = false;
  int? _remoteUid;
  List<int> _remoteUids = [];
  bool _isMuted = false;

  Map<int, bool> remoteUserMuteStates = {};
  Map<int, bool> remoteUserMuteVideoStates = {};


  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    setupVoiceSDKEngine();
  }

  void showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> setupVoiceSDKEngine() async {
    await [Permission.microphone].request();
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));
    agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        showMessage("Local user joined the channel");
        setState(() {
          _isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        showMessage("Remote user joined the channel");
        setState(() {
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
        showMessage("Remote user left the channel");
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
    ));
    join();
  }

  void join() async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.joinChannel(
      token: widget.agoratoken,
      channelId: widget.channelId,
      options: options,
      uid: 0,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    agoraEngine.muteLocalAudioStream(_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    print("CHANNEL CHANNEL CHANNEL===========");
    print(widget.channelId);
    return Scaffold(
      backgroundColor: Colors.black, // Example background color
      body: SafeArea(
        child: Stack(
          children: [
            // Contact Information
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildContactInfo())),

            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Local user audio tile
                    _buildUserTile(uid: 0, isLocal: true),
                    // Remote user audio tile (show only if a remote user joins)
                    if (_remoteUid != null)
                      _buildUserTile(uid: _remoteUid!, isLocal: false),
                  ],
                ),
              ),
            ),

            // Call Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 58.0),
                child: _buildCallControls(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
                NetworkImage('${widget.imageUrl}'),
          ),
          const SizedBox(height: 15),
          Text(
            '${widget.fname} ${widget.lname}',
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          if (_callDurationInSeconds > 0)
          Text(
            formattedCallDuration,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
          // Additional details (optional)
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.call_end),
        ),
        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: () => null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.mic_off),
        ),
        // Additional controls (speakerphone, etc.)
      ],
    );
  }

  Widget _buildUserTile({required int uid, required bool isLocal}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isLocal ? 'Local User' : 'Remote User'),
          const SizedBox(height: 10),
          // Replace with appropriate widget that displays audio activity (e.g., mic icon with pulsating animation)
          const Icon(Icons.mic, size: 40),
          // Replace with a more appropriate widget
        ],
      ),
    );
  }
}
