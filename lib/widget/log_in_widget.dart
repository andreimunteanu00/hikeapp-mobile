import 'package:flutter/material.dart';

import '../main.dart';
import '../service/auth.service.dart';
import '../util/singe_page_route.dart';

class LogInWidget extends StatelessWidget {
  final AuthService authService = AuthService.instance;

  LogInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: InkWell(
        onTap: () async {
          await authService.signIn();
          Navigator.pushReplacement(
            context,
            SlidePageRoute(
              widget: const Main(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.dst), // Apply transparent color filter
            child: Opacity(
              opacity: 0.75, // Adjust the opacity value between 0.0 and 1.0
              child: Image.asset(
                'assets/images/login.png',
                fit: BoxFit.scaleDown,
              ),
            )
          )
        ),
      ),
    );
  }
}
