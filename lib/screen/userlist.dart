import 'package:flutter/material.dart';
import 'package:flutter_caht_module/screen/individular_chat.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../collection/fb_collections.dart';
import '../controllers/individual_chat_controller.dart';
import '../controllers/profilecontroller.dart';
import '../firebase_services/auth_services.dart';
import '../model/recent_chat.dart';
import '../utils/ScreenUtils.dart';
import '../utils/Utils.dart';
import '../utils/color_code.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BaseAuth _auth = Auth();
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor:
          Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
      body: GetBuilder<ProfileController>(builder: (controller) {
        return ListView.builder(
          itemCount: controller.userList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                var individualChatController =

                Get.put(IndividualChatController());
                individualChatController.userToken="";
                individualChatController.getFirebaseToken(controller.userList[index].id);
                individualChatController.userModel = controller.userList[index];
                individualChatController.messageList.clear();
                individualChatController.getMessages(controller.userList[index]);
                Get.to(IndividualChat(),arguments:controller.userList[index] );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            controller.userList[index].profileImage!,
                          ), // Replace with the actual image URL
                        ),
                        const SizedBox(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              controller.userList[index].fname!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                            const Text(
                              'Last message',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14.0),
                            )
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('12:34 PM',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  _appBar(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(Get.height * 0.09), //
      child: Padding(
        padding: EdgeInsets.only(top: Get.height * 0.03),
        child: AppBar(
          backgroundColor:
              Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Image.asset(
                    "assets/svg/left-arrow.png",
                    height: Get.height * 0.1,
                    width: Get.width * 0.09,
                    color: Colors.white,
                  ),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : SizedBox(),
          actions:  [
             IconButton(
               onPressed: ()async {
                 print("SDF SDF SDF SDF SDF ");
               var data=  getData();

               },
               icon: Image.asset("assets/svg/bell.png"),
               iconSize: ScreenUtils.isSmallScreen(context)
                   ? Get.width * 0.06
                   : Get.width * 0.04,
             ).paddingOnly(right: 12)
          ],
          titleSpacing: 0,
          title: Text(
            'All User List'.toUpperCase(),
            style: TextStyle(
                fontFamily: 'Poppins Regular',
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: ScreenUtils.isSmallScreen(context)
                    ? Get.width * 0.04
                    : Get.width * 0.03),
          ),
        ),
      ),
    );
  }

  getData()async{
    List<ChatModel>chatmoel=[];
    List<QueryDocumentSnapshot> chatDocuments = await getAllChats();

    for (QueryDocumentSnapshot document in chatDocuments) {
      Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
     print('Chat Document ID: ${document.id}');
    // print('Chat Data: $chatData');
      chatmoel.add(ChatModel.fromJson(chatData));
    }

    chatmoel.forEach((element) {

      print(element.lastMessage);
    });

    return chatDocuments;
  }


  Future<List<QueryDocumentSnapshot>> getAllChats() async {
    var chatsCollection = FirebaseFirestore.instance.collection('chats')
        .where('commonusers',
        arrayContains: '${Get.find<ProfileController>().usermodel.value.id}');

    QuerySnapshot chatQuerySnapshot = await chatsCollection.get();

    return chatQuerySnapshot.docs;
  }


}
