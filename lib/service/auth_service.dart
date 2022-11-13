import 'package:google_sign_in/google_sign_in.dart';

import '../util/constants.dart' as constants;


class AuthService {

  final GoogleSignIn googleSignIn = GoogleSignIn(
    // TODO should be env variable + switch between android and ios
    serverClientId: '125789040129-i90b31ck9jagtob63ts73ntpnfvh7at7.apps.googleusercontent.com',
    scopes: <String>[constants.email]
  );

  Future<bool> checkSignIn() async {
    return googleSignIn.isSignedIn();
  }

  Future<bool> signOut() async {
    await googleSignIn.signOut();
    return false;
  }

  Future<bool> signIn() async {
    GoogleSignInAccount? signInAccount = await googleSignIn.signIn();
    // TODO call backend
    if (signInAccount?.id != null) {
      return true;
    }
    return false;
  }

}