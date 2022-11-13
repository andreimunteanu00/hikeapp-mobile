import 'package:flutter/material.dart';

import '../service/auth_service.dart';

class SignOutWidget extends StatelessWidget {

  final AuthService authService;
  final Function onChange;

  const SignOutWidget(this.authService, this.onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Sign Out'),
      onPressed: () async {
        bool val = await authService.signOut();
        onChange(val);
      }
    );
  }
}