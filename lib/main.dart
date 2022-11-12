import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId: '125789040129-i90b31ck9jagtob63ts73ntpnfvh7at7.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/userinfo.profile'
  ],
);

void _signOut() async {
  googleSignIn.signOut();
}

void _signInUsingGoogle() async {

  print(googleSignIn);
  bool isSignedIn = await googleSignIn.isSignedIn();

  // after 1st time signin
  if (isSignedIn) {
    print("user name signed in");
  } else {
    // first-time sign in
    GoogleSignInAccount? signInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication? signInAuthentication = await signInAccount?.authentication;
    print('TOKEN: ${signInAuthentication?.accessToken}');
    print('ID TOKEN: ${signInAuthentication?.idToken}');
  }
}


class SignInDemo extends StatefulWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: Row(
          children: [
            TextButton(
              child: Text('Sign in'),
              onPressed: () => _signInUsingGoogle(),
            ),
            TextButton(
              child: Text('Sign OUT'),
              onPressed: () => _signOut(),
            )
          ],
        )
    );
  }
}