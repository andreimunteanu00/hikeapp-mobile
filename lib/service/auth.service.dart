import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hikeappmobile/model/user.model.dart';
import 'package:hikeappmobile/util/my_http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/constants.dart' as constants;
import 'package:http/http.dart' as http;

class AuthService {
  static AuthService? _instance;

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(
      // TODO should be env variable + switch between android and ios
      serverClientId:
          '125789040129-i90b31ck9jagtob63ts73ntpnfvh7at7.apps.googleusercontent.com',
      scopes: <String>['email']);

  Future<User> getCurrentUser() async {
    final response = await MyHttp.getClient()
        .get(Uri.parse('${constants.localhost}/auth/currentUser'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<bool> checkSignIn() async {
    return googleSignIn.isSignedIn();
  }

  Future<void> removeTokenToLocalStorage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('token');
  }

  Future<bool> signOut() async {
    await removeTokenToLocalStorage();
    await googleSignIn.signOut();
    return false;
  }

  Future<http.Response> generateToken(String googleId, String email) {
    return http.post(Uri.parse('${constants.localhost}/auth/$googleId/$email'));
  }

  Future<void> saveTokenToLocalStorage(String jwt) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('token', jwt);
  }

  Future<bool> signIn() async {
    GoogleSignInAccount? signInAccount = await googleSignIn.signIn();
    if (signInAccount?.id != null && signInAccount?.email != null) {
      final response =
          await generateToken(signInAccount!.id, signInAccount.email);
      if (response.body.isEmpty) {
        return false;
      }
      await saveTokenToLocalStorage(response.body);
      return true;
    }
    return false;
  }
}
