import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/constants.dart' as constants;
import 'package:http/http.dart' as http;


class AuthService {

  final GoogleSignIn googleSignIn = GoogleSignIn(
    // TODO should be env variable + switch between android and ios
    serverClientId: '125789040129-i90b31ck9jagtob63ts73ntpnfvh7at7.apps.googleusercontent.com',
    scopes: <String>[constants.email]
  );

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

  Future<http.Response> generateToken(String googleId) {
    return http.get(Uri.parse('${constants.localhost}/auth/$googleId'));
  }

  Future<void> saveTokenToLocalStorage(String jwt) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('token', jwt);
  }

  Future<bool> signIn() async {
    GoogleSignInAccount? signInAccount = await googleSignIn.signIn();
    if (signInAccount?.id != null) {
      final response = await generateToken(signInAccount!.id);
      if (response.body.isEmpty) {
        return false;
      }
      await saveTokenToLocalStorage(response.body);
      return true;
    }
    return false;
  }

}