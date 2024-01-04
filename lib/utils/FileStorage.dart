import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// To save the file in the device
class FileStorage {
  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url + '/' + fileName;
      print(myUrl);
      final folderName = "some_name";
      final path = Directory("storage/emulated/0/$folderName");
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("CODE IS RUNNING HERE");
        var bytes = await consolidateHttpClientResponseBytes(response);
        //   print(bytes);
        filePath = "$path";
        if ((await path.exists())) {
          file = File(filePath);
          await file.writeAsBytes(bytes);
        } else {
          // TODO:
          print("not exist");
          path.create();
          file = File(filePath);
          await file.writeAsBytes(bytes);
        }
        // file = File(filePath);
        // await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      print(ex);
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  Future<void> downloadAndSaveImage() async {
    try {
      // Fetch the image from the URL
      final response = await http.get(Uri.parse(
          'https://media.istockphoto.com/id/1276936276/photo/creative-background-online-casino-in-a-mans-hand-a-smartphone-with-playing-cards-roulette-and.jpg?s=1024x1024&w=is&k=20&c=Hd5hqc5Ey6IqZmPKvmXjfclw9E5OR5x_-AXjEvGDvWM='));
      if (response.statusCode == 200) {
        // Get the external storage directory
        Directory? directory = await getExternalStorageDirectory();

        print(directory!.path);
        if (directory != null) {
          Directory customDirectory = Directory('${directory.path}/ICEF');
          if (!customDirectory.existsSync()) {
            customDirectory.createSync(recursive: true);
          }
          File file = File('${customDirectory?.path}/image.jpg');

          // Write the downloaded image data to the file
          await file.writeAsBytes(response.bodyBytes);

          print('Image downloaded and saved to: ${file.path}');
        } else {
          print('Failed to download image: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
}
