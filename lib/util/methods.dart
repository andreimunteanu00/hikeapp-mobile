import 'dart:convert';
import 'dart:io';

class Methods {

  static String fileToBase64(File file) {
    List<int> fileBytes = file.readAsBytesSync();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

}