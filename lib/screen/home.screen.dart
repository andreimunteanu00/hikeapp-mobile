import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/first_login.screen.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';

import 'home_logged.screen.dart';


class HomeScreen extends StatefulWidget {

  final AuthService authService;
  final Function onChange;

  const HomeScreen(this.authService, this.onChange, {super.key});

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
          builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data?.firstLogin == true ? FirstLoginScreen(snapshot.data!) : const HomeLoggedScreen();
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
            return const CircularProgressIndicator();
          }
        ),
        SignOutWidget(widget.authService, widget.onChange)
      ],
    );
  }

}