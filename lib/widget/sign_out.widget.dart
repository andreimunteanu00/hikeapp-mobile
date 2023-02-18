import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../service/auth.service.dart';
import '../util/constants.dart' as constants;
import '../util/my_http.dart';

class SignOutWidget extends StatefulWidget {

  final AuthService authService = AuthService.instance;
  final Function onChange;

  SignOutWidget(this.onChange, {super.key});

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
            bool val = await widget.authService.signOut();
            widget.onChange(val);
          }
        )
      ],
    );
  }
}