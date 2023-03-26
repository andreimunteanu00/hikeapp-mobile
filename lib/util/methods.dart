import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Methods {
  static String fileToBase64(File file) {
    List<int> fileBytes = file.readAsBytesSync();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

  static Future<String> giveGoogleIdFromToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;
    if (token.isEmpty) {
      return "";
    }
    final parts = token.split('.');
    final String encodedPayload = parts[1];
    final payloadData =
        utf8.fuse(base64).decode(base64.normalize(encodedPayload));
    Map<String, dynamic> payload = json.decode(payloadData);
    return payload['sub'];
  }

  static Future<String> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('token')!;
  }
}
