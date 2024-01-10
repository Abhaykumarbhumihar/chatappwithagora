import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caht_module/agora_code/agora_audio/voice_call_start.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../agora_code/video_call_start.dart';
import '../agora_code/videocall_pojo.dart';
import '../collection/fb_collections.dart';
import '../firebase_services/auth_services.dart';
import '../model/Message.dart';
import '../model/UserModel.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class IndividualChatController extends GetxController {
  final BaseAuth _auth = Auth();
  TextEditingController textController = TextEditingController();
  GroupedItemScrollController scrollController = GroupedItemScrollController();
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  TextEditingController captionController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCallDetails();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getCallDetails();
  }

  /// call calling or ringing
  final _callringingornotstatus = "".obs;

  String get callringingornotstatus => _callringingornotstatus.value;

  set callringingornotstatus(String status) {
    _callringingornotstatus.value = status;
    update();
  }

  /// call active or disconnect
  final _callactiveornotstatus = true.obs;

  bool get callactiveornotstatus => _callactiveornotstatus.value;

  set callactiveornotstatus(bool status) {
    _callactiveornotstatus.value = status;
    update();
  }

  /// audio call active or disconnect
  final _audiocallactiveornotstatus = true.obs;

  bool get audiocallactiveornotstatus => _audiocallactiveornotstatus.value;

  set audiocallactiveornotstatus(bool status) {
    _audiocallactiveornotstatus.value = status;
    update();
  }

  /// audio call calling or ringing
  final _audiocallringingornotstatus = "".obs;

  String get audiocallringingornotstatus => _audiocallringingornotstatus.value;

  set audiocallringingornotstatus(String status) {
    _audiocallringingornotstatus.value = status;
    update();
  }

  final _userToken = "".obs;

  String get userToken => _userToken.value;

  set userToken(String flag) {
    _userToken.value = flag;
    update();
  }

  final _lastSeen = "".obs;

  String get lastSeen => _lastSeen.value;

  set lastSeen(String lastseen) {
    _lastSeen.value = lastseen;
    update();
  }

  final _isPageOpen = false.obs;

  bool get isPageOpen => _isPageOpen.value;

  set isPageOpen(bool flag) {
    _isPageOpen.value = flag;
    update();
  }

  final _imageSelect = false.obs;

  bool get imageSelect => _imageSelect.value;

  set imageSelect(bool flage) {
    _imageSelect.value = flage;
    update();
  }

  /*
  *
  * for set typing status
  *
  * */
  final _isTyping = false.obs;

  bool get isTyping => _isTyping.value;

  set isTyping(bool flag) {
    _isTyping.value = flag;
    update();
  }

  final _replymessageid = Message().obs;

  Message get replymessageid => _replymessageid.value;

  set replymessageid(Message messageId) {
    _replymessageid.value = messageId;
    update();
  }

  final _isReply = false.obs;

  bool get isReply => _isReply.value;

  set isReply(bool flag) {
    _isReply.value = flag;
    update();
  }

  final Rx<File?> _image = Rx<File?>(null);

  File get image => _image.value!;

  set image(File? file) {
/*todo---jb ye true hoga means view me image send krne wla view show hoga*/
    imageSelect = true;
    _image.value = file;
    update();
  }

  var chatIdd = "";

  /*todo--message list*/
  List<Message> messageList = [];

  final List<Message> copymessageList = []; // Your list of messages

  List<String> deletemessageListt = [];

  List<String> get deletemessageList => deletemessageListt;

  void addToDeletemessageList(String item) {
    if (deletemessageList.contains(item)) {
      deletemessageListt.remove(item);

      update();
    } else {
      deletemessageListt.add(item);
      update();
    }

    if (deletemessageListt.isEmpty) {
      isMessageSelect = false;
    } else {
      isMessageSelect = true;
    }
    update(); // Use the update method to trigger UI updates
  }

  final _showEmoji = false.obs;

  /*todo---get current loggedin user id*/
  String get currentUserid => _auth.getCurrentUser()!.uid;

  final _isMessageSelect = false.obs;

  bool get isMessageSelect => _isMessageSelect.value;

  set isMessageSelect(bool flag) {
    _isMessageSelect.value = flag;
    update();
  }

  final _chatType = "text".obs;

  String get chatType => _chatType.value;

  set chatType(String type) {
    _chatType.value = type;
    update();
  }

  final _userModel = UserModel().obs;

  UserModel get userModel => _userModel.value;

  set userModel(UserModel userModel) {
    _userModel.value = userModel;
    update();
  }

  bool get showEmoji => _showEmoji.value;

  set showEmoji(bool flag) {
    _showEmoji.value = flag;
    update();
  }

  /*todo---if sendChatButton is true means user have type any thing in message field , so mike button will be replace with send button*/
  final _sendChatButton = false.obs;

  bool get sendChatButton => _sendChatButton.value;

  set sendChatButton(bool flage) {
    _sendChatButton.value = flage;
    update();
  }

  /*todo--agr isMessageSelectforDelete true hoga to app bar deleted wala hoga nhi to normal appbar hoag*/
  // final _isMessageSelectforDelete = false.obs;
  bool get isMessageSelectforDelete => deletemessageList.isEmpty ? false : true;

  // set isMessageSelectforDelete(bool flag) {
  //   _isMessageSelectforDelete.value = flag;
  //   update();
  // }

  /*todo----send messag*/
  sendMessage(UserModel userModel, message, type,
      {fileurl = "", contactname = "", contactnumber = ""}) async {
    /*todo---for make room name*/
    var userlist = [];
    userlist.add(userModel.id);
    userlist.add(_auth.getCurrentUser()!.uid);

    userlist.sort();
    print(userlist.join('-'));

    /*todo---other user data*/
    Map<String, dynamic> userData1 = {
      'id': userModel.id,
      'fname': userModel.fname,
      'lanme': userModel.lname,
      'email': userModel.email,
      'profileimage': userModel.profileImage,
    };

    /*todo---current user data*/
    Map<String, dynamic> userData2 = {
      "id": _auth.getCurrentUser()!.uid,
      'fname': Get.find<ProfileController>().usermodel.value.fname,
      'lanme': Get.find<ProfileController>().usermodel.value.lname,
      'email': Get.find<ProfileController>().usermodel.value.email,
      'profileimage':
          Get.find<ProfileController>().usermodel.value.profileImage,
      'message_type': chatType,
    };

    Map<String, dynamic> userData = {
      "user_one": userData1,
      "user_two": userData2,
      'lastmessage': message,
      'deletemessage': [],
      'sendtime': "${DateTime.now().millisecondsSinceEpoch.toString()}",
      'message_type': chatType,
      'commonusers': [userModel.id!, _auth.getCurrentUser()!.uid]
    };

// Reference to the chat document inside the "chats" collection
    DocumentReference chatDocument = FirebaseFirestore.instance
        .collection('chats')
        .doc('${userlist.join('-')}');

// Add user data to the chat document
    await chatDocument.set(userData);

// Reference to the "message" subcollection inside the chat document
    CollectionReference messageCollection = chatDocument.collection('message');

// Add a document to the "message" subcollection and store its ID in the document data
    /*todo-----message data*/

    Map<String, dynamic> messageData = {
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'sender_id': _auth.getCurrentUser()!.uid,
      'receiver_id': userModel.id,
      'deletemessageuser': [],
      'media_url': fileurl,
      "message_type": chatType,
      "contact_name": contactname,
      "contact_number": contactnumber,
      /*todo--agr delete for me kiya to dono ka id isme update hoga , agr only for me kiya to jo user delete kiya hai bs uska id*/
      'deletetype': "",
      /*ye only sender hi krega*/
      'replymessageData': replymessageid.toMap(),
      'isReply': isReply,
      'isReadBySender': true, // set to true for the sender
      'isReadByReceiver': false, // set to false for the receiver
    };

// Add the document to the "message" subcollection and store its ID in the "message_id" field
    DocumentReference messageDocumentRef =
        await messageCollection.add(messageData);
    messageData['message_id'] = messageDocumentRef.id;

// Update the document in the "message" subcollection with the "message_id" field
    await messageDocumentRef.set(messageData);
    /*todo-----Send notification code here*/
    sendNotification(message + "");
    replymessageid = Message();
    isReply = false;
    goonLastindex();
    update();
// Now, the "message_id" field in the message document contains the document's ID
  }

  goonLastindex() {
    scrollController.scrollTo(
      index: messageList.length - 1, // Adjust the index as needed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Function to mark a message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    DocumentReference messageDocumentRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('message')
        .doc(messageId);

    // Update the document in the "message" subcollection with the "isRead" field
    await messageDocumentRef.update({
      'isReadByReceiver': true,
    });
  }

  Future<void> updateDeleteLastMessageArray(String type) async {
    //print("CODE IS HERE  n");
    var userlist = [];
    userlist.add(userModel.id);
    userlist.add(_auth.getCurrentUser()!.uid);

    userlist.sort();

    DocumentReference chatDocument = FirebaseFirestore.instance
        .collection('chats')
        .doc('${userlist.join('-')}');

    // Fetch the existing data
    DocumentSnapshot snapshot = await chatDocument.get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    var lastmessage = "";

    //print("Getting data here   ");
    if (data != null) {
      if (type == "forme") {
        // Update the 'deletemessage' array
        List<dynamic> existingDeleteMessages = data['deletemessage'];
        existingDeleteMessages.add(_auth
            .getCurrentUser()!
            .uid); // Add the new delete messages to the existing ones
        data['deletemessage'] = existingDeleteMessages;

        // Set the updated data back to the document
        await chatDocument.update(data);
      } else {
        // Update the 'deletemessage' array
        List<dynamic> existingDeleteMessages = data['deletemessage'];
        existingDeleteMessages.add(_auth
            .getCurrentUser()!
            .uid); // Add the new delete messages to the existing ones
        existingDeleteMessages.add(userModel.id);

        data['deletemessage'] = existingDeleteMessages;

        // Set the updated data back to the document
        await chatDocument.update(data);
      }
    } else {
      print("Document does not exist");
    }
  }

  void copyToClipboard(List<String> messages, BuildContext context) {
    String concatenatedMessages = messages.join('\n');
    Clipboard.setData(ClipboardData(text: concatenatedMessages));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Messages copied to clipboard'),
    ));
  }

/*todo----delete for me*/
  /*todo----delete for me only current user k side se message delete hone */

  /*todo--agr type me forme pass hoga to only current user ka id deletemessageuser me push hoga nhi to dono ka id push hoga*/
  deleteMessage(String type) {
    var userlist = [];
    userlist.add(userModel.id);
    userlist.add(_auth.getCurrentUser()!.uid);

    userlist.sort();
    //print(userlist.join('-'));
    DocumentReference chatDocument = FirebaseFirestore.instance
        .collection('chats')
        .doc('${userlist.join('-')}');

    CollectionReference messageCollection = chatDocument.collection('message');
/*todo--deletemessageListt is list me selected message ka id store hai*/
    List<String> idsToUpdate = deletemessageListt;

    if (type == "forme") {
      for (var id in idsToUpdate) {
        messageCollection.doc(id).update({
          /*todo-----FieldValue.arrayUnion   "deletemessageuser" is array ke previcious item ko remove nhi krega*/
          "deletemessageuser":
              FieldValue.arrayUnion([_auth.getCurrentUser()!.uid])
        });
      }
    } else {
      for (var id in idsToUpdate) {
        messageCollection.doc(id).update({
          /*todo-----FieldValue.arrayUnion   "deletemessageuser" is array ke previcious item ko remove nhi krega*/
          "deletemessageuser":
              FieldValue.arrayUnion([_auth.getCurrentUser()!.uid, userModel.id])
        });
      }
    }

    deletemessageListt.clear();
    isMessageSelect = false;
    update();
  }

  String formatMillisecondsSinceEpoch(
      {String millisecondsSinceEpochString = "1693917692239"}) {
    // Convert the string back to an integer
    int millisecondsSinceEpoch = int.parse(millisecondsSinceEpochString);

    // Create a DateTime object from the milliseconds since epoch
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    // Format the DateTime object to 'hh:mm' format
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      final format = DateFormat.jm();
      return format.format(dateTime);
    } else if (dateTime.year == now.year) {
      final format = DateFormat('MMM d');
      return format.format(dateTime);
    } else {
      final format = DateFormat('MMM d, y');
      return format.format(dateTime);
    }
  }

  updateTypingStaus(bool flage) async {
/*for add typing status*/
    DocumentSnapshot chatDocumentSnapshot =
        await FirebaseFirestore.instance.collection('chats').doc(chatIdd).get();

    if (chatDocumentSnapshot.exists) {
      Map<String, dynamic>? chatData =
          chatDocumentSnapshot.data() as Map<String, dynamic>?;

      if (chatData != null) {
        Map<String, dynamic> userTwoData =
            chatData['user_two'] as Map<String, dynamic>? ?? {};

        // Update the 'typing' field within the user_two data
        userTwoData['typing'] = flage;

        // Update the Firestore document with the modified user_two data
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatIdd)
            .update({'user_two': userTwoData});
      }
    }
  }

  Stream<List<Message>> getUserssStream(chatId) {
    // Create a stream of snapshots for the users collection
    Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('message')
        .orderBy('timestamp')
        // Optional: Order messages by timestamp
        .snapshots();

    // Use a Stream transformer to map the snapshots to a list of UserModel objects
    Stream<List<Message>> usersListStream = userStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        // Assuming you have a sender_id field in your Message class
        String senderId = userData['sender_id'];

        // Check if the current user is the receiver of the message
        if (currentUserid == userData['receiver_id'] &&
            !userData['isReadByReceiver']) {
          // Call the function to mark the message as read
          markMessageAsRead(chatId, doc.id);
          userData['isReadByReceiver'] = true; // Update the local value
        }

        // Set the isRead field to true when fetching the message
        //userData['isRead'] = true;

        return Message.fromMap(userData);
      }).toList();
    });

    return usersListStream;
  }

  getMessages(UserModel userModel) {
    getFirebaseToken(userModel.id);
    var userlist = [];
    userlist.add(userModel.id);
    userlist.add(_auth.getCurrentUser()!.uid);

    userlist.sort();

    chatIdd = "";
    chatIdd = '${userlist.join('-')}';
    getUserssStream('${chatIdd}').listen((messageListdata) {
      messageList.forEach((element) {
        //   print("\n" + element.text.toString() + "   chatid " + chatIdd);
      });
      //goonLastindex();

      messageList = messageListdata;
      update();
    }, onError: (error) {
      print('Error getting users: $error');
    });
  }

  Future<String> sendImageMessage(
      UserModel userModel, message, File imageFile) async {
    var userlist = [];
    userlist.add(userModel.id);
    userlist.add(_auth.getCurrentUser()!.uid);

    userlist.sort();

    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child(
        'chat_image/${userlist.join('-')}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() => null);

    if (taskSnapshot.state == TaskState.success) {
      print(TaskState.success);

      final imageUrl = await storageRef.getDownloadURL();
      /*todo----send image with all data on firestore*/
      sendMessage(userModel, message, chatType, fileurl: imageUrl);
      return imageUrl;
    } else {
      print("Image upload failed");
      throw 'Image upload failed';
    }
  }

  getReplyMessage(repliedMessageId) async {
    // Reference to the chat document inside the "chats" collection
    DocumentReference chatDocument =
        FirebaseFirestore.instance.collection('chats').doc(chatIdd);

// Reference to the "message" subcollection inside the chat document
    CollectionReference messageCollection = chatDocument.collection('message');

// Create a query to retrieve messages that reply to the specified message
    Query repliedMessageQuery =
        messageCollection.where("replymessageid", isEqualTo: repliedMessageId);

// Get the documents that match the query
    QuerySnapshot repliedMessages = await repliedMessageQuery.get();

// Loop through the documents to access the replied messages
    repliedMessages.docs.forEach((messageDoc) {
      Map<String, dynamic> messageData =
          messageDoc.data() as Map<String, dynamic>;
      // Now you have access to the replied message data.
      // Handle the replied message data here...
      print(messageData);
      // Message repliedMessage = Message.fromMap(messageData);
      //
      // // Add the parsed Message object to the list
      //
      // return  repliedMessage;
    });
  }

  getChannelName(id) async {}

/*todo--------get token from firebase*/
  Future<String?> getFirebaseToken(userId) async {
    print("CODE IS WORKING");
    try {
      Stream<DocumentSnapshot> stream =
          FBCollections.tokens.doc('${userId}').snapshots();

      stream.listen((DocumentSnapshot docSnapshot) {
        if (docSnapshot.exists) {
          Map<String, dynamic> userData =
              docSnapshot.data() as Map<String, dynamic>;

          String token = userData['token'];
          print(token);
          String id = userData['id'];

          var lastseen = userData['lastseen'];
          if (lastseen == "Online") {
            lastSeen = "Online";
          } else {
            DateTime lastSeenTime =
                DateTime.fromMillisecondsSinceEpoch(int.parse(lastseen));
            lastSeen = "last seen at " + _formatDateTime(lastSeenTime);
          }
          userToken = token;
          update();
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
    return null;
  }

  void sendNotification(message) async {
    // Define the FCM server URL and your server key
    const String url = 'https://fcm.googleapis.com/fcm/send';
    const String serverKey =
        'AAAANcFY6wc:APA91bGdR-KzHpXAzGitxe38XO_3WkO8m1aBwmY5jQ5WsiFhVOHyY1l5kfF7oPloUURyIVrE-LGKIGGxcpyc1Ujsh4DuzFXMrizpR0IL2E1FuzqtgHZGAjFmoCLfAat8Se3qdLKzz5JU'; // Replace with your actual server key

    // Define the JSON payload to send
    final Map<String, dynamic> payload = {
      "data": {
        "title": "Chat Module",
        "body": "$message",
        "custom_key": "$chatIdd"
      },
      "to": "$userToken"
    };

    // Define the headers, including the Authorization header with your server key
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    try {
      // Send the POST request to FCM
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print("Notification sent successfully");
      } else {
        print(
            "Failed to send notification. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  ///agora setup start form here==============.
  void makeCall(userId, fname, imageUrl, channelId, context, lname) async {
    print("MAKE CALL RUNNING HERE");

    var userlist = [];
    userlist.add(userId);
    userlist.add(_auth.getCurrentUser()!.uid);
    userlist.sort();
    print(userlist.join('-'));
    Map<String, dynamic> userData = {
      "receiverid": userId,
      "receiverfname": fname,
      "receiverlname": lname,
      "receiverimage": imageUrl,
      "sendername":
          "${Get.find<ProfileController>().usermodel.value.fname} ${Get.find<ProfileController>().usermodel.value.lname}",
      "senderimage":
          "${Get.find<ProfileController>().usermodel.value.profileImage}",
      "senderid": _auth.getCurrentUser()!.uid,
      "channelid": channelId,
      'commonusers': [userId, _auth.getCurrentUser()!.uid],
      'activecall': true,
      'callingstatus': "calling",
      'calldisconnectby': ''
    };
    await FBCollections.videocall.doc(userlist.join('-')).set(userData);
    print("CHAT CREATED HEREEE ${channelId}");
    await fetchDataforcreater(
        channelId, context, userId, fname, imageUrl, lname,"video");
    getFirebaseTokenforcall(userId, channelId, fname, imageUrl,"video",true,false);
  }

  ///call ring ho raha ya nahi ye update krne k liye
  callringingornot(callid) async {
    Map<String, dynamic> userData = {
      'callingstatus': "ringing",
    };
    await FBCollections.videocall.doc(callid).update(userData);
  }


  ///call disconnect
  leaveDisconnectCall(userId,context) async {
    //userId====caller ka id hai
    // var userlist = [];
    // userlist.add(userId);
    // userlist.add(_auth.getCurrentUser()!.uid);
    // userlist.sort();
    // print(userlist.join('-'));
    Map<String, dynamic> userData = {
      'activecall': false,
      'calldisconnectby': _auth.getCurrentUser()!.uid
    };
    await FBCollections.videocall.doc(userId).update(userData);
    Navigator.pop(context);
  }

  fetchDataforcreater(
      channelName, context, userId, name, imageUrl, lname,calltype) async {
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
if(calltype=="video"){
  Get.to(VideoCallScreen(
    imageUrl: imageUrl,
    fname: name,
    lname: lname,
    userId: userId,
    receivecall: true,
    channelId: channelName,
    agoratoken: responseData['data'],
  ));
}else {
  Get.to(VoiceCallScrenn(
    imageUrl: imageUrl,
    fname: name,
    lname: lname,
    userId: userId,
    receivecall: true,
    channelId: channelName,
    agoratoken: responseData['data'],
  ));
}





      // Handle the token as needed
      print('Token: $token');
    } else {
      // Handle errors
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<String?> getFirebaseTokenforcall(
      userID, channelidd, name, imageUrl,calltype,isvideocall,isvoicecall) async {
    try {
      DocumentSnapshot docSnapshot =
          await FBCollections.tokens.doc('${userID}').get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;
        String token = userData['token'];
        String id = userData['id'];
        print('Token: $token');
        print('ID: $id');
        userToken = token;
        update();
        sendNotificationforcall("Video call ", channelidd, userData['token'],
            userID, name, imageUrl,calltype,isvideocall,isvoicecall);
        return token;
      } else {
        print('Document does not exist for $userID');
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
    return null;
  }

  void sendNotificationforcall(
      message, channelid, token, userID, name, imageUrl,calltype,isvideocall,isvoicecall) async {
    // Define the FCM server URL and your server key
    const String url = 'https://fcm.googleapis.com/fcm/send';
    const String serverKey =
        'AAAANcFY6wc:APA91bGdR-KzHpXAzGitxe38XO_3WkO8m1aBwmY5jQ5WsiFhVOHyY1l5kfF7oPloUURyIVrE-LGKIGGxcpyc1Ujsh4DuzFXMrizpR0IL2E1FuzqtgHZGAjFmoCLfAat8Se3qdLKzz5JU'; // Replace with your actual server key

    // Define the JSON payload to send
    final Map<String, dynamic> payload = {
      //

      "data": {
        "title": "Video Call",
        "body": message,
        "custom_key": "videocall",
        "videocall": isvideocall,
        "voicecall":isvoicecall,
        "channelid": channelid,
        "userid": _auth.getCurrentUser()!.uid, //ye jo call krega uska id hai,
        "receiverid": userID,
        "fname": Get.find<ProfileController>().usermodel.value.fname.toString(),
        "lname": Get.find<ProfileController>().usermodel.value.lname.toString(),
        "imageurl": Get.find<ProfileController>().usermodel.value.profileImage,
        "calltype":calltype
      },
      "to": "$token"
    };
    print(payload);

    // Define the headers, including the Authorization header with your server key
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    try {
      // Send the POST request to FCM
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print("Notification sent successfully ${response.body}");
      } else {
        print(
            "Failed to send notification. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
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
        _callactiveornotstatus(false);
        _callringingornotstatus("");
      }else{
        for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
          Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
          VideoCallData videoCallData = VideoCallData.fromMap(chatData);
          print("CALL STATUS RUNNING");
          print(videoCallData.channelId);
          print(videoCallData.receiverfname);
          print(videoCallData.senderName);
          print(videoCallData.activeCall);
          _callactiveornotstatus(videoCallData.activeCall);
          _callringingornotstatus(videoCallData.callingstatus);
          update();
        }
      }

    });
  }





  ///agora audio call------------------audio call-----------------------audio call------------
  void makeAudioCall(userId, fname, imageUrl, channelId, context, lname) async {
    print("MAKE CALL RUNNING HERE");

    var userlist = [];
    userlist.add(userId);
    userlist.add(_auth.getCurrentUser()!.uid);
    userlist.sort();
    print(userlist.join('-'));
    Map<String, dynamic> userData = {
      "receiverid": userId,
      "receiverfname": fname,
      "receiverlname": lname,
      "receiverimage": imageUrl,
      "sendername":
      "${Get.find<ProfileController>().usermodel.value.fname} ${Get.find<ProfileController>().usermodel.value.lname}",
      "senderimage":
      "${Get.find<ProfileController>().usermodel.value.profileImage}",
      "senderid": _auth.getCurrentUser()!.uid,
      "channelid": channelId,
      'commonusers': [userId, _auth.getCurrentUser()!.uid],
      'activecall': true,
      'callingstatus': "calling",
      'calldisconnectby': '',

    };
    await FBCollections.audioCall.doc(userlist.join('-')).set(userData);
    print("CHAT CREATED HEREEE ${channelId}");
    await fetchDataforcreater(
        channelId, context, userId, fname, imageUrl, lname,"audio");
    getFirebaseTokenforcall(userId, channelId, fname, imageUrl,"audio",false,true);
  }


  Future<void> getAudioCallDetails() async {

    if (Get.find<ProfileController>() == null) {
      Get.put(ProfileController());
    }
    String userId = Get.find<ProfileController>().usermodel.value.id!;
    var chatsCollection = FirebaseFirestore.instance
        .collection('Audiocall')
        .where('commonusers', arrayContains: userId)
        .where('activecall', isEqualTo: true);
    Stream<QuerySnapshot> chatStream = chatsCollection.snapshots();

    chatStream.listen((QuerySnapshot chatQuerySnapshot) {
      if (chatQuerySnapshot.docs.isEmpty) {
        // No documents found
        print("No active calls found");
        _audiocallactiveornotstatus(false);
        _audiocallringingornotstatus("");

      }else{
        for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
          Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
          VideoCallData videoCallData = VideoCallData.fromMap(chatData);
          print("CALL STATUS RUNNING");
          print(videoCallData.channelId);
          print(videoCallData.receiverfname);
          print(videoCallData.senderName);
          print(videoCallData.activeCall);
          _audiocallactiveornotstatus(videoCallData.activeCall);
          _audiocallringingornotstatus(videoCallData.callingstatus);
          update();
        }
      }

    });
  }

  audiocallringingornot(callid) async {
    Map<String, dynamic> userData = {
      'callingstatus': "ringing",
    };
    await FBCollections.audioCall.doc(callid).update(userData);
  }
}
