import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State createState() => HomeScreenState();

}

class HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('logged!'),
        SignOutWidget()
      ],
    );
  }
}
