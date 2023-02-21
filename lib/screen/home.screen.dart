import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/first_login.screen.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'account_suspended.screen.dart';
import 'home_logged.screen.dart';


class HomeScreen extends StatefulWidget {

  final AuthService authService = AuthService.instance;

  HomeScreen({super.key});

  @override
  State createState() => HomeScreenState();

}

class HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder<User>(
            future: widget.authService.getCurrentUser(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data?.active == false) {
                  return const AccountSuspendedScreen();
                } else {
                  return snapshot.data?.firstLogin == true ? FirstLoginScreen(snapshot.data!) : const HomeLoggedScreen();
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            }
        ),
      ],
    );
  }

}