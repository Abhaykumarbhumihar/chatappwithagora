class VideoCallData {
  final String receiverId;
  final String receiverfname;
  final String receiverlname;
  final String receiverImage;
  final String senderName;
  final String senderImage;
  final String senderId;
  final String channelId;
  final List<String> commonUsers;
  final bool activeCall;
  final String callingstatus;
  final String calldisconnectby;

  VideoCallData({
    required this.receiverId,
    required this.receiverfname,
    required this.receiverImage,
    required this.senderName,
    required this.senderImage,
    required this.senderId,
    required this.channelId,
    required this.commonUsers,
    required this.activeCall,
    required this.calldisconnectby,
    required this.callingstatus,
    required this.receiverlname
  });

  factory VideoCallData.fromMap(Map<String, dynamic> map) {
    return VideoCallData(
        receiverlname:map['receiverlname'],
      receiverId: map['receiverid'],
        receiverfname: map['receiverfname'],
      receiverImage: map['receiverimage'],
      senderName: map['sendername'],
      senderImage: map['senderimage'],
      senderId: map['senderid'],
      channelId: map['channelid'],
      commonUsers: List<String>.from(map['commonusers']),
      activeCall: map['activecall'],
      calldisconnectby: map['callingstatus'],
      callingstatus: map['calldisconnectby']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverid': receiverId,
      'receiverfname': receiverfname,
      'receiverimage': receiverImage,
      'sendername': senderName,
      'senderimage': senderImage,
      'senderid': senderId,
      'channelid': channelId,
      'commonusers': commonUsers,
      'activecall': activeCall,
      'calldisconnectby':calldisconnectby,
      'callingstatus':callingstatus,
      'receiverlname':receiverlname
    };
  }
}
