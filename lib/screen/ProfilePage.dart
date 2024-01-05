import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:flutter_caht_module/controllers/recentchat_controller.dart';
import 'package:flutter_caht_module/screen/individular_chat.dart';
import 'package:flutter_caht_module/screen/recentchat.dart';
import 'package:flutter_caht_module/screen/userlist.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../utils/ScreenUtils.dart';
import '../utils/Utils.dart';
import '../utils/color_code.dart';
import '../widgets/logintextfield.dart';


class ProfilePage extends StatelessWidget {
  final controller = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              // You can customize the icon size, color, and onPressed callback as needed
              size: 30,
              color: Colors.black,
            ),
            onPressed: () {
              //Get.off(RecentChat());
              var myController = Get.isRegistered<RecentChatController>()
                  ? Get.find<RecentChatController>()
                  : Get.put(RecentChatController());
              myController.getData();
             // Get.to(IndividualChat());
              Get.back();

           },
          ),
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              // You can customize the icon size, color, and onPressed callback as needed
              size: 30,
              color: Colors.black,
            ),
            onPressed: () {
              Get.find<ProfileController>().logout();
            },
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(builder: (controller) {
        return SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(height * 0.06),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.openDialog(context);
                      },
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: controller.image.value != null
                            ? Image.file(
                                controller.image.value!,
                                fit: BoxFit.cover,
                              ).image
                            : NetworkImage(
                                controller.usermodel.value.profileImage ??
                                    ""), // Replace with your image
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.isEditMode = !controller.isEditMode;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  'First Name',
                  'admin@gmail.com',
                  '',
                  controller: controller.fnameController,
                  isDisable: controller.isEditMode,
                ),
                Gap(height * 0.03),
                TextFieldWidget(
                  'Last name',
                  'admin@gmail.com',
                  '',
                  controller: controller.lnameController,
                  isDisable: controller.isEditMode,
                ),
                Gap(height * 0.03),
                TextFieldWidget(
                  'Email',
                  'admin@gmail.com',
                  '',
                  isDisable: false,
                  isEmail: true,
                  controller: controller.emailController,
                ),
                Gap(height * 0.04),
                controller.isEditMode
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.06, right: width * 0.06),
                        child: Utils().createButton(
                            context,
                            "Update Profile",
                            width,
                            ScreenUtils.isSmallScreen(context)
                                ? (ScreenUtils.isSmallfont(context)
                                    ? height * 0.07
                                    : height * 0.07)
                                : height * 0.07, () {
                          controller.updateProfileWithImage();
                        }),
                      )
                    : const SizedBox(),




              ],
            ),
          ),
        );
      }),
    );
  }
}
