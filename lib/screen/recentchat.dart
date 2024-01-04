import 'package:flutter/material.dart';
import 'package:flutter_caht_module/controllers/individual_chat_controller.dart';
import 'package:flutter_caht_module/controllers/recentchat_controller.dart';
import 'package:flutter_caht_module/model/UserModel.dart';
import 'package:flutter_caht_module/screen/ProfilePage.dart';
import 'package:flutter_caht_module/screen/userlist.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/profilecontroller.dart';
import '../utils/ScreenUtils.dart';
import '../utils/Utils.dart';
import '../utils/color_code.dart';
import 'individular_chat.dart';

class RecentChat extends StatelessWidget {
  final controller = Get.put(RecentChatController());

  RecentChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getData();
    return Scaffold(
      appBar: _appBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const UserList());
          Get.find<ProfileController>().getUserss();
        },
        backgroundColor: const Color(0xFF25D366), // WhatsApp green color
        child: Icon(
          Icons.message,
          color: Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
        ),
      ),
      backgroundColor:
          Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
      body: GetBuilder<RecentChatController>(builder: (controller) {
        return ListView.builder(
          itemCount: controller.recentChatList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                UserModel? userModel;
                if (controller.recentChatList[index].userOne!.id ==
                    controller.currentUserId) //means login user hai is came me user two ka data lena hai
                {
                  //set user two data
                  userModel = UserModel(
                      fname: controller.recentChatList[index].userTwo!.fname!,
                      password: "sdfsd",
                      email: controller.recentChatList[index].userTwo!.email!,
                      id: controller.recentChatList[index].userTwo!.id!,
                      lname: controller.recentChatList[index].userTwo!.lanme!,
                      profileImage: controller
                          .recentChatList[index].userTwo!.profileImage!);
                } else {
                //means login user nahi hai is came me user one ka data lena hai
                  //send user one data
                  userModel = UserModel(
                      fname: controller.recentChatList[index].userOne!.fname!,
                      password: "sdfsd",
                      email: controller.recentChatList[index].userOne!.email!,
                      id: controller.recentChatList[index].userOne!.id!,
                      lname: controller.recentChatList[index].userOne!.lanme!,
                      profileImage: controller
                          .recentChatList[index].userOne!.profileImage!);
                }
                var individualChatController =
                    Get.put(IndividualChatController());
                individualChatController.userToken="";
                individualChatController.userModel = userModel;
                //jis user se chat kr rhe hai uska token get krne k liye
                individualChatController.getFirebaseToken(userModel.id);
                //jis user se chat kr rhe hai uska previcious message get krne k liye
                individualChatController.getMessages(userModel);

                individualChatController.messageList.clear();
                Get.to(IndividualChat(), arguments: userModel);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        //todo--profile view
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            controller.recentChatList[index].userOne!.id ==
                                    controller.currentUserId
                                ? controller.recentChatList[index].userTwo!
                                    .profileImage!
                                : controller.recentChatList[index].userOne!
                                    .profileImage!,
                          ), // Replace with the actual image URL
                        ),
                        const SizedBox(width: 24),
                        //todo---name and lastmessage view
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              controller.recentChatList[index].userOne!.id ==
                                      controller.currentUserId
                                  ? controller
                                      .recentChatList[index].userTwo!.fname!
                                  : controller
                                      .recentChatList[index].userOne!.fname!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                            Container(
                              constraints: BoxConstraints(maxWidth: 230),
                              child: Text(
                                controller.recentChatList[index].lastMessage!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    //todo---time view
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                          formatMillisecondsSinceEpoch(
                              millisecondsSinceEpochString:
                                  controller.recentChatList[index].sendTime!),
                          style: const TextStyle(
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
                  onPressed: () {},
                )
              : const SizedBox(),
          actions: [
            IconButton(
              onPressed: () async {
                Get.to(ProfilePage());
              },
              icon: Icon(Icons.account_circle_outlined),
              iconSize: ScreenUtils.isSmallScreen(context)
                  ? Get.width * 0.09
                  : Get.width * 0.09,
            ).paddingOnly(right: 12),


          ],
          titleSpacing: 0,
          title: Text(
            'recent chat'.toUpperCase(),
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
}
