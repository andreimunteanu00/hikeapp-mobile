import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/user.model.dart';
import '../util/constants.dart' as constants;

class UserService {
  static UserService? _instance;

  UserService._();

  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  // TODO refactor this
  Future<void> saveUserData(User user) async {
    final response = await MyHttp.getClient()
        .put(Uri.parse('${constants.localhost}/user/update'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(user.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to save data');
    }
  }

  Future<bool> checkFieldDuplicate(String columnName, String? value) async {
    final response = await MyHttp.getClient().get(
        Uri.parse(
            '${constants.localhost}/user/checkFieldDuplicate/${columnName}/${value}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    return response.body == 'true' ? true : false;
  }
}
