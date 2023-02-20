import 'package:flutter/material.dart';

import '../main.dart';
import '../service/auth.service.dart';
import '../util/singe_page_route.dart';

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
            Navigator.pushReplacement(
              context,
              SlidePageRoute(
                widget: const Main(),
              ),
            );
          }
        )
      ],
    );
  }
}