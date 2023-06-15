import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/log_in_widget.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State createState() => LogInScreenState();
}

class LogInScreenState extends State<LogInScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        body: Center(child: LogInWidget()),
      ),
    );

  }
}
