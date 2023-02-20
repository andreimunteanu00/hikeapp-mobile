import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';

class HomeLoggedScreen extends StatefulWidget {

  const HomeLoggedScreen({super.key});

  @override
  State createState() => HomeLoggedScreenState();

}

class HomeLoggedScreenState extends State<HomeLoggedScreen> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('logged!'),
        SignOutWidget()
      ],
    );
  }
}
