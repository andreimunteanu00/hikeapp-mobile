import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Methods {

  static String fileToBase64(File file) {
    List<int> fileBytes = file.readAsBytesSync();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

  static Future<String> giveUsernameFromToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;
    if (token == null) {
      return "";
    }
    final parts = token.split('.');
    final String encodedPayload = parts[1];
    String decoded = utf8.decode(base64Url.decode(encodedPayload));
    Map<String, dynamic> payload = json.decode(decoded);
    String username = payload['username'];
    return username;
  }

}