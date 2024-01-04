class ChatModel {
  String? lastMessage;
  List<String>? commonUsers;
  List<String>? deletemessage;
  String? messageType;
  String? sendTime;
  UserDetail? userTwo;
  UserDetail? userOne;

  ChatModel({
     this.lastMessage,
     this.commonUsers,
     this.messageType,
     this.sendTime,
     this.userTwo,
     this.userOne,
    this.deletemessage
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      lastMessage: json['lastmessage'] ?? '',
      commonUsers: List<String>.from(json['commonusers'] ?? []),
      messageType: json['message_type'] ?? '',
      sendTime: json['sendtime']??'',
      userOne: UserDetail.fromJson(json['user_one'] ?? {}),
      userTwo: UserDetail.fromJson(json['user_two'] ?? {}),
      deletemessage: List<String>.from(json['deletemessage'] ?? []),
    );
  }
}

class UserDetail {
  String? fname;
  String? lanme;
  String? email;
  String? profileImage;
  String? id;

  UserDetail({
    this.id,
     this.fname,
     this.lanme,
     this.email,
     this.profileImage,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      fname: json['fname'] ?? '',
      id: json['id'] ?? '',
      lanme: json['lanme'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileimage'] ?? '',
    );
  }
}
