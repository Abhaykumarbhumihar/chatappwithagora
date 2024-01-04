import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';



class FBCollections {
  static FirebaseFirestore fb = FirebaseFirestore.instance;
  static CollectionReference users = fb.collection('Users');
  static CollectionReference tokens=fb.collection('Tokens');
  static CollectionReference videocall=fb.collection('Videocall');
  static CollectionReference chats = fb.collection('Chats');
  static CollectionReference message = fb.collection('message');
  static CollectionReference brands = fb.collection('Brands');
  static CollectionReference genderType = fb.collection('GenderType');
  static CollectionReference shoes = fb.collection('shoes');


}
