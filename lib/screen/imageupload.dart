import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _imageFile;
  UploadTask? _uploadTask;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _startUpload() async {
    if (_imageFile == null) return;

    final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');

    setState(() {
      _uploadTask = storageRef.putFile(_imageFile!);
    });

    await _uploadTask!.whenComplete(() async {
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('images').add({
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Image uploaded successfully');
      setState(() {
        _uploadTask = null;
        _imageFile = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('Select an image to upload')
                : Image.file(_imageFile!),
            SizedBox(height: 20.0),
            _uploadTask != null
                ? StreamBuilder<TaskSnapshot>(
              stream: _uploadTask!.snapshotEvents,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final taskSnapshot = snapshot.data!;
                  final progress =
                      taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
                  final percentage = (progress * 100).toStringAsFixed(2);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(width: 10.0),
                          Text('$percentage% Uploaded'),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return SizedBox.shrink();
                }
              },
            )
                : SizedBox.shrink(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _imageFile == null || _uploadTask != null ? null : _startUpload,
              child: Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}
