import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../service/auth_service.dart';
import '../util/constants.dart' as constants;
import '../util/my_http.dart';

class SignOutWidget extends StatefulWidget {

  final AuthService authService;
  final Function onChange;

  const SignOutWidget(this.authService, this.onChange, {super.key});

  @override
  State createState() => SignOutWidgetState();
}

class SignOutWidgetState extends State<SignOutWidget> {

  String str = '';

  void test() async {
    http.Response response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/test'));
    final x = response.body;
    setState(() {
      str = x;
    });
  }

  @override
  void initState() {
    test();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(str),
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