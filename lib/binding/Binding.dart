import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:flutter_caht_module/controllers/recentchat_controller.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';


class Binding extends Bindings {
  @override
  void dependencies() {


    Get.put(() => LoginController());
    Get.put(() => ProfileController());
    Get.put(() => RecentChatController());

  }
}
