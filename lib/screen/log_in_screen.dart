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
    return Scaffold(body: Center(child: LogInWidget()));
  }
}