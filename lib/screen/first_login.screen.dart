import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/first_login.widget.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'account_suspended.screen.dart';


class FirstLoginScreen extends StatefulWidget {

  final AuthService authService = AuthService.instance;

  FirstLoginScreen({super.key});

  @override
  State createState() => FirstLoginScreenState();

}

class FirstLoginScreenState extends State<FirstLoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<User>(
              future: widget.authService.getCurrentUser(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.active == false) {
                    return const AccountSuspendedScreen();
                  } else {
                    return FirstLoginWidget(snapshot.data!);
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }
          ),
        ],
      )
    ));
  }

}