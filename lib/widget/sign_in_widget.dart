import 'package:flutter/material.dart';

import '../service/auth_service.dart';

class SignInWidget extends StatelessWidget {

  final AuthService authService;
  final Function onChange;

  const SignInWidget(this.authService, this.onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Sign in'),
      onPressed: () async {
        authService.signIn().then((value) => onChange(value));
      }
    );
  }

}