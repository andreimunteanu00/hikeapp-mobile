import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/user.model.dart';
import '../util/constants.dart' as constants;

class UserService {

  Future<void> saveUserData(User user) async {
    print(json.encode(user.toJson()));
    final response = await MyHttp.getClient().put(Uri.parse('${constants.localhost}/user/save'), body: json.encode(user.toJson()));
    if (response.statusCode == 200) {
      // success
    } else {
      throw Exception('Failed to save data');
    }
  }

}