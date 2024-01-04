class Message {
  String? text;
  String? timestamp;
  String? senderId;
  String? messageId;
  List<String>? deleteMessageUser;
  String? deleteType;
  String? mediaurl;
  String? messageType;
  String? contactName;
  String? contactNumber;
  bool? isReply;
  ReplyMessage? replyMessageData;

  Message({
    this.text,
    this.timestamp,
    this.senderId,
    this.deleteMessageUser,
    this.isReply,
    this.deleteType,
    this.messageId,
    this.mediaurl,
    this.messageType,
    this.contactNumber,
    this.contactName,
    this.replyMessageData,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'],
      isReply: map['isReply'],
      messageId: map['message_id'],
      messageType: map['message_type'],
      contactNumber: map['contact_number'],
      contactName: map['contact_name'],
      timestamp: map['timestamp'],
      senderId: map['sender_id'],
      mediaurl: map['media_url'],
      deleteMessageUser: List<String>.from(map['deletemessageuser'] ?? []),
      deleteType: map['deletetype'],
      replyMessageData: ReplyMessage.fromMap(map['replymessageData']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isReply': isReply,
      'timestamp': timestamp,
      'sender_id': senderId,
      'replymessageData': replyMessageData?.toMap(),
      'message_type': messageType,
      'contact_number': contactNumber,
      'contact_name': contactName,
      'message_id': messageId,
      'media_url': mediaurl,
      'deletemessageuser': deleteMessageUser,
      'deletetype': deleteType,
    };
  }
}

class ReplyMessage {
  String? text;
  String? timestamp;
  String? senderId;
  String? messageId;
  List<String>? deleteMessageUser;
  String? deleteType;
  String? mediaurl;
  String? messageType;
  String? contactName;
  String? contactNumber;
  String? replyMessageId;

  ReplyMessage({
    this.text,
    this.timestamp,
    this.senderId,
    this.deleteMessageUser,
    this.deleteType,
    this.messageId,
    this.mediaurl,
    this.messageType,
    this.contactNumber,
    this.contactName,
    this.replyMessageId,
  });

  factory ReplyMessage.fromMap(Map<String, dynamic> map) {
    return ReplyMessage(
      text: map['text'],
      messageId: map['message_id'],
      messageType: map['message_type'],
      contactNumber: map['contact_number'],
      contactName: map['contact_name'],
      timestamp: map['timestamp'],
      senderId: map['sender_id'],
      mediaurl: map['media_url'],
      deleteMessageUser: List<String>.from(map['deletemessageuser'] ?? []),
      deleteType: map['deletetype'],
      replyMessageId: map['replymessageid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp,
      'sender_id': senderId,
      'replymessageid': replyMessageId,
      'message_type': messageType,
      'contact_number': contactNumber,
      'contact_name': contactName,
      'message_id': messageId,
      'media_url': mediaurl,
      'deletemessageuser': deleteMessageUser,
      'deletetype': deleteType,
    };
  }
}