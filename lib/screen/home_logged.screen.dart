import 'package:flutter/material.dart';

class HomeLoggedScreen extends StatefulWidget {

  const HomeLoggedScreen({super.key});

  @override
  State createState() => HomeLoggedScreenState();

}

class HomeLoggedScreenState extends State<HomeLoggedScreen> {

  @override
  Widget build(BuildContext context) {
    return const Text('after first loggin!');
  }
}