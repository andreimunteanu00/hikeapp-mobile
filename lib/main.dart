import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/first_login.screen.dart';
import 'package:hikeappmobile/screen/log_in_screen.dart';
import 'package:hikeappmobile/service/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './util/constants.dart' as constants;
import './util/routes.dart';
import 'model/user.model.dart';
import 'screen/main.screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: constants.appTitle,
      home: const Main(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final String? name = settings.name;
        final Function? pageBuilder = Routes.routes[name];
        if (pageBuilder != null) {
          return MaterialPageRoute(builder: (context) => pageBuilder(context));
        }
        return null;
      },
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State createState() => MainState();
}

class MainState extends State<Main> {
  final AuthService authService = AuthService.instance;
  late bool isLogged = true;
  late bool afterFirstLogIn = false;
  bool isLoading = true;

  _toggleIsLogged(val) {
    setState(() {
      isLogged = val;
    });
  }

  _asyncMethod() async {
    authService.checkSignIn().then((value) => _toggleIsLogged(value));
    if (isLogged) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString("token");
      if (token == null || token.isEmpty) {
        _toggleIsLogged(await authService.signOut());
      } else {
        User user = await authService.getCurrentUser();
        setState(() {
          afterFirstLogIn = isLogged && !user.firstLogin! && user.active!;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: CircularProgressIndicator())
        : !isLogged
            ? const LogInScreen()
            : (afterFirstLogIn ? const MainScreen() : FirstLoginScreen());
  }
}
