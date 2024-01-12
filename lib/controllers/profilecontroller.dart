import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caht_module/utils/Utils.dart';
import 'package:get/get.dart';

import '../collection/fb_collections.dart';
import '../firebase_services/auth_services.dart';
import '../model/UserModel.dart';
import '../screen/splash_screen.dart';

class ProfileController extends GetxController {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var usermodel = UserModel().obs;
  final _isEditMode = false.obs;
  final BaseAuth _auth = Auth();
  Rx<File?> image = Rx<File?>(null);
  Rx<PlatformFile?> imagePlatformFile = Rx<PlatformFile?>(null);

  var isSelectedforImage = "".obs;
  List<UserModel> userList = [];

  bool get isEditMode => _isEditMode.value;

  set isEditMode(bool flag) {
    _isEditMode.value = flag;
    update();
  }

  final _isHovered = false.obs;
  bool get isHovered => _isHovered.value;

  set isHovered(bool flag) {
    _isHovered.value = flag;
    update();
  }


  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  @override
  void onReady() {
    // Get called after widget is rendered on the screen
    super.onReady();
  }

  getUserProfile() async {
    var data = await _auth.getUserData(_auth.getCurrentUser()!.uid);
    usermodel.value = UserModel.fromMap(data.data() as Map<String, dynamic>);
    fnameController.text = usermodel.value.fname!;
    lnameController.text = usermodel.value.lname!;
    emailController.text = usermodel.value.email!;
    print(usermodel.value.profileImage);
  }

  updateProfile(imageUril) async {
    Map<String, dynamic> userData = {
      'fname': fnameController.value.text,
      'lanme': lnameController.value.text,
      'email': emailController.value.text,
      'password': usermodel.value.password,
      'profile_image': imageUril
    };
    await FBCollections.users.doc(_auth.getCurrentUser()!.uid).update(userData);
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(SplashScreen());
  }

  updateProfileWithImage() async{

    if(kIsWeb){
      if (imagePlatformFile.value != null) {
        File file = await File(imagePlatformFile.value!.path!);
        uploadImage(file);
      } else {
        updateProfilewithoutImage();
      }
    }else{
      if (image.value != null) {
        uploadImage(image.value!);
      } else {
        updateProfilewithoutImage();
      }
    }


  }

  updateProfilewithoutImage() async {

    Map<String, dynamic> userData = {
      'fname': fnameController.value.text,
      'lanme': lnameController.value.text,
      'email': emailController.value.text,
      'password': usermodel.value.password,
      'profile_image':'https://www.brasscraft.com/wp-content/uploads/2017/01/no-image-available.png'
    };
    await FBCollections.users.doc(_auth.getCurrentUser()!.uid).update(userData);
  }

  Future<String> uploadImage(File imageFile) async {
    print('RUNNING IN uploadImage  RUNNING IN uploadImage  RUNNING IN uploadImage  RUNNING IN uploadImage ');
    final storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child(
        'profile_images/${_auth.getCurrentUser()!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() => null);

    if (taskSnapshot.state == TaskState.success) {
      print(TaskState.success);

      final imageUrl = await storageRef.getDownloadURL();
      print("SDF SDF  NO IMAGGG ====== $imageUrl");
      print(imageUrl);
      updateProfile(imageUrl);
      return imageUrl;
    } else {
      print("Image upload failed");
      throw 'Image upload failed';
    }
  }

  openDialog(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return chooseImage(context);
      },
    );
  }

  chooseImage(context) {
    return AlertDialog(
      title: const Text('Select Image Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              Navigator.of(context, rootNavigator: true).pop();
               //image.value = await Utils.openGallery(Get.context!);
              // print("image.value image.value image.value$image.value");
             imagePlatformFile.value= await Utils.pickImage();

             print("SDF SDF ====SDF SDF ====SDF SDF ======SDF SDF====");

              update();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.of(context, rootNavigator: true).pop();
              image.value = await Utils.openCame(Get.context!);
              update();
            },
          ),
        ],
      ),
    );
  }

  Future<void> getUsers() async {
    try {
      userList = [];
      QuerySnapshot querySnapshot = await FBCollections.users.get();
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        if (_auth.getCurrentUser()!.uid != doc.id) {
          print("User Data: $userData");
          userList.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        // print("User Data: $userData");
        // userList.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
      });
      print(userList);
    } catch (e) {
      print('Error getting users: $e');
    }
  }

  // Future<void> getUserss() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FBCollections.users.get();
  //
  //     userList = querySnapshot.docs
  //         .map((doc) {
  //           Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
  //           return UserModel.fromMap(userData);
  //         })
  //         .where((user) => user.id != _auth.getCurrentUser()!.uid)
  //         .toList();
  //     update();
  //   } catch (e) {
  //     print('Error getting users: $e');
  //   }
  // }

  Stream<List<UserModel>> getUserssStream() {
    // Create a stream of snapshots for the users collection
    Stream<QuerySnapshot> userStream = FBCollections.users.snapshots();

    // Use a Stream transformer to map the snapshots to a list of UserModel objects
    Stream<List<UserModel>> usersListStream = userStream.map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
            return UserModel.fromMap(userData);
          })
          .where((user) => user.id != _auth.getCurrentUser()!.uid)
          .toList();
    });

    return usersListStream;
  }

// Call this function to start listening for updates
  getUserss() {
    getUserssStream().listen((usersList) {
      // Update your userList and trigger a UI update here
      userList = usersList;
      update();
    }, onError: (error) {
      print('Error getting users: $error');
    });
  }

  // getFirebaseToken(){
  //   DocumentReference chatDocument = FBCollections.tokens
  //       .doc('${_auth.getCurrentUser()!.uid}');
  //   print(chatDocument);
  // }

  Future<String?> getFirebaseToken(userID) async {
    try {
      DocumentSnapshot docSnapshot = await FBCollections
          .tokens
          .doc('${_auth.getCurrentUser()!.uid}')
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;

        String token = userData['token'];
        String id = userData['id'];
        print('Token: $token');
        print('ID: $id');
        return token;

      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
    return null;
  }
}

//  Align(
//                       alignment: Alignment.centerRight,
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           maxWidth: MediaQuery.of(context).size.width - 45,
//                         ),
//                         child: Card(
//                           elevation: 1,
//                           shape:
//                           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           color: Colors.purple[100],
//                           margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                           child: Stack(children: [
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 10, right: 60, top: 5, bottom: 20),
//                               child: Text(
//                                 msg,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 4,
//                               right: 10,
//                               child: Row(
//                                 children: [
//                                   Text(time,
//                                       style:
//                                       TextStyle(fontSize: 13, color: Colors.grey[600])),
//                                   SizedBox(
//                                     width: 5,
//                                   ),
//                                   Icon(Icons.done_all, size: 20)
//                                 ],
//                               ),
//                             )
//                           ]),
//                         ),
//                       ))
