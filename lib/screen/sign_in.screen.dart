import 'package:flutter/material.dart';

import '../service/auth.service.dart';

class SignInWidget extends StatelessWidget {

  final AuthService authService = AuthService.instance;
  final Function onChange;

  SignInWidget(this.onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Log In'),
      onPressed: () async {
        authService.signIn().then((value) => onChange(value));
      }
    );
  }

}