import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/log_in_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const LogInScreen(),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        )
      ],
    );
  }
}