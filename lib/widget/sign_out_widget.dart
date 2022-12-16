import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../service/auth_service.dart';
import '../util/constants.dart' as constants;

class SignOutWidget extends StatelessWidget {

  final AuthService authService;
  final Function onChange;

  const SignOutWidget(this.authService, this.onChange, {super.key});

  Future<String> test() async {
    http.Response response = await http.get(Uri.parse('${constants.localhost}/test'));
    print(response.body);
    return response.body;
  }

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