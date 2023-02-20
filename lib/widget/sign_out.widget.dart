import 'package:flutter/material.dart';

import '../main.dart';
import '../service/auth.service.dart';

class SignOutWidget extends StatefulWidget {

  final AuthService authService = AuthService.instance;

  SignOutWidget({super.key});

  @override
  State createState() => SignOutWidgetState();
}

class SignOutWidgetState extends State<SignOutWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text('Sign Out'),
          onPressed: () async {
            await widget.authService.signOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Main()));
          }
        )
      ],
    );
  }
}