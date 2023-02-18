import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/user.model.dart';
import '../util/constants.dart' as constants;

class UserService {

  Future<void> saveUserData(User user) async {
    final response = await MyHttp.getClient().post(
      Uri.parse('${constants.localhost}/user/save'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(user.toJson())
    );
    if (response.statusCode == 200) {
      // success
    } else {
      throw Exception('Failed to save data');
    }
  }

  Future<bool> checkFieldDuplicate(String columnName, String value) async {
    final response = await MyHttp.getClient().get(
      Uri.parse('${constants.localhost}/user/checkFieldDuplicate/${columnName}/${value}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );
    return response.body == 'true' ? true : false;
  }

}