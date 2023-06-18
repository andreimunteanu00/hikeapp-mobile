import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/first_login.widget.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'account_suspended.screen.dart';
import '../util/constants.dart' as constants;


class FirstLoginScreen extends StatefulWidget {
  final AuthService authService = AuthService.instance;
  final bool fromSetup;

  FirstLoginScreen({super.key, required this.fromSetup});

  @override
  State createState() => FirstLoginScreenState();
}

class FirstLoginScreenState extends State<FirstLoginScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.fromSetup);

    return Scaffold(
        appBar: !widget.fromSetup ? AppBar(title: const Text(constants.appTitle)) : null,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<User>(
                    future: widget.authService.getCurrentUser(),
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.active == false) {
                          return const AccountSuspendedScreen();
                        } else {
                          return FirstLoginWidget(snapshot.data!, widget.fromSetup);
                        }
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    }),
              ],
    )),
            )
          ],
        ));
  }
}
