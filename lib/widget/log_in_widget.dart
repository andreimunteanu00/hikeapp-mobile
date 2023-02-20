import 'package:flutter/material.dart';

import '../main.dart';
import '../service/auth.service.dart';
import '../util/singe_page_route.dart';

class LogInWidget extends StatelessWidget {

  final AuthService authService = AuthService.instance;

  LogInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Log In'),
      onPressed: () async {
        await authService.signIn();
        Navigator.pushReplacement(
          context,
          SlidePageRoute(
            widget: const Main(),
          ),
        );
      }
    );
  }

}