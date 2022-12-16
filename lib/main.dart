import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hikeappmobile/service/auth_service.dart';
import 'package:hikeappmobile/widget/sign_in_widget.dart';
import 'package:hikeappmobile/widget/sign_out_widget.dart';


void main() {
  runApp(
    const MaterialApp(
      title: 'HikeApp',
      home: Main(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State createState() => MainState();
}

class MainState extends State<Main> {

  final AuthService authService = AuthService();
  late bool isLogged = true;

  @override
  void initState() { super.initState();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    authService.checkSignIn().then((value) => _toggleIsLogged(value));
    if (isLogged) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString("token");
      if (token == null || token.isEmpty) {
        _toggleIsLogged(await authService.signOut());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        //TODO to be modified with loginScreen / homeScreen
        child: !isLogged ? SignInWidget(authService, _toggleIsLogged) : SignOutWidget(authService, _toggleIsLogged)
      )
    );
  }

  _toggleIsLogged(val) {
    setState(() {
      isLogged = val;
    });
  }
}