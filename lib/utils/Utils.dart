import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caht_module/utils/CommonDialog.dart';
import 'package:flutter_caht_module/utils/ScreenUtils.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'color_code.dart';

class Utils {
  static final String SESSION_ID = "Poppins BlackItalic";

  static hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }

  Widget createButton(context, text, width, height, onpressed,controller) {


    return Builder(
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.elasticOut,
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: controller.isHovered ? 1.3 : 1.0,
              child: ElevatedButton(
                onHover: (hovered) {
                  controller.isHovered=hovered;
                },
                onPressed: onpressed,
                style: ElevatedButton.styleFrom(
                  elevation: controller.isHovered ? 2.0 : 0.0,

                  backgroundColor: backgroundColoris(controller.isHovered,context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.09),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  fixedSize: Size(width, height),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: (width < 800 ? width * 0.05 : width * 0.03 - 5),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins Medium",
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color backgroundColoris(ishovered,context){
    print("$ishovered in backgroundColoris  $ishovered  in backgroundColoris");
    if(ScreenUtils.isLargeScreen(context)){
      if(ishovered){
        return Colors.white;
      }else{
        return Color(Utils.hexStringToHexInt(ColorsCode.createButtonColor));
      }
    }else{
      return Color(Utils.hexStringToHexInt(ColorsCode.createButtonColor));
    }
  }




  Widget titleText1(text, context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins Regular',
          fontSize: MediaQuery.of(context).size.height * 0.02,
          color: Colors.black),
    );
  }

  Widget titleTextsemibold(text, context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins Semibold',
          fontSize: MediaQuery.of(context).size.height * 0.03,
          color: Colors.black),
    );
  }

  static Future<File?> openCame(BuildContext context) async {
    // ignore: deprecated_member_use
    final ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      /*todo---this is for use image rotation stop*/
      File rotatedImage =
          await FlutterExifRotation.rotateAndSaveImage(path: image.path);
      return rotatedImage;
    }
    return null;
  }

  static Future<File?> openGallery(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    var picture = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    print("IN UTILS ${picture}");
    if (picture != null) {
      File rotatedImage =
          await FlutterExifRotation.rotateAndSaveImage(path: picture.path);
      print("IN rotatedImage rotatedImage  ${rotatedImage}");
      return rotatedImage;
    }
  }

  static Future<List<File>?> pickDocument() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      return files;
    } else {
      // User canceled the picker
    }
    return null;
  }

  static Future<List<File>?> pickAudio() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
       // type: FileType.audio,
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'],
        allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      return files;
    } else {
      // User canceled the picker
    }
    return null;
  }

 static Future<Contact?> pickContact() async {
    // Check if we have permission to access contacts.
    final PermissionStatus status = await Permission.contacts.request();

    if (status.isGranted) {
      // Permission granted, pick a contact.
      final contact = await ContactsService.openDeviceContactPicker();

      if (contact != null) {
        print("Selected contact: ${contact.displayName}");
        return contact;
        // You can access other contact properties like phone numbers, emails, etc.
      }
    } else {
      await Permission.contacts.request();
      // Handle the case where permission is denied.
      CommonDialog.showErrorDialog1(title: "Please give contact permission in setting",description: "For use this , you need to give contact permission");
    }
    return null;
  }
}
