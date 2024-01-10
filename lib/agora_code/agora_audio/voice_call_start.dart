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
  late RtcEngine agoraEngine;
  bool _isJoined = false;
  int? _remoteUid;

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
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        showMessage("Remote user left the channel");
        setState(() {
          _remoteUid = null;
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

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            height: 10,
          ),
          Text(
            '25:00',
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
          child: const Icon(Icons.call_end),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: () => null,
          child: const Icon(Icons.mic_off),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
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
