import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_caht_module/controllers/profilecontroller.dart';
import 'package:get/get.dart';

import '../agora_code/videocall_pojo.dart';
import '../firebase_services/auth_services.dart';
import '../model/UserModel.dart';
import '../model/recent_chat.dart';

class RecentChatController extends GetxController {
  final BaseAuth auth = Auth();
  List<ChatModel> recentChatList = [];

  String get currentUserId => auth.getCurrentUser()!.uid;

  final _showRecent = false.obs;

  bool get showIndividual => _showRecent.value;

  set showIndividual(bool flag) {
    _showRecent.value = flag;
    update();
  }

  final _isShowAlluser = false.obs;
  bool get isShowAllUSer => _isShowAlluser.value;

  set isShowAllUSer(bool flag) {
    _isShowAlluser.value = flag;
    update();
  }




  final _isRecentChat = false.obs;

  bool get isRecentChat => _isRecentChat.value;

  set isRecentChat(bool flag) {
    _isRecentChat.value = flag;
    update();
  }

  final RxInt _hoveredIndex = (-1).obs;

  int get hoveredIndex => _hoveredIndex.value;

  set hoveredIndex(int flag) {
    _hoveredIndex.value = flag;
    update();
  }



  final _userModel = UserModel().obs;

  UserModel get userModel => _userModel.value;

  set userModel(UserModel userModel) {
    _userModel.value = userModel;
    update();
  }

  @override
  void onInit() {
    Get.put(ProfileController());
    super.onInit();
    getData();

  }

  @override
  void onReady() {
    super.onReady();
    Get.put(ProfileController()).getUserProfile();
    getData();
  }



  getData() {
    recentChatList = [];
    update();

       if (Get.find<ProfileController>() == null) {
         Get.put(ProfileController());
       }

       var chatsCollection = FirebaseFirestore.instance.collection('chats').where(
           'commonusers',
           arrayContains: '${Get.find<ProfileController>().usermodel.value.id}');

       // Create a stream of snapshots for the chat collection
       Stream<QuerySnapshot> chatStream = chatsCollection.snapshots();

       // Listen for changes in the chat collection
       chatStream.listen((QuerySnapshot chatQuerySnapshot) {
         recentChatList.clear(); // Clear the existing list

         for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
           Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
           // print('Chat Document ID: ${document.id}');
           // print('Chat Data: $chatData');
           // recentChatList.sort((a, b) {
           //   DateTime timeA = DateTime.parse(a.sendTime ?? '1970-01-01');
           //   DateTime timeB = DateTime.parse(b.sendTime ?? '1970-01-01');
           //   return timeB.compareTo(timeA);
           // });
           recentChatList.add(ChatModel.fromJson(chatData));
           update();
         }

         update();
      refresh();
    });
  }
}
