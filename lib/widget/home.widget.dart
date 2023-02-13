import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/first_login.widget.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';


class HomeWidget extends StatefulWidget {

  final AuthService authService;
  final Function onChange;

  const HomeWidget(this.authService, this.onChange, {super.key});

  @override
  State createState() => HomeWidgetState();

}

class HomeWidgetState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder<User>(
          future: widget.authService.getCurrentUser(),
          builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FirstLoginWidget(snapshot.data!);
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