import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/home.screen.dart';
import 'package:hikeappmobile/widget/log_in_widget.dart';
import 'package:hikeappmobile/service/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './util/routes.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'HikeApp',
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
        child: !isLogged ? LogInWidget() : HomeScreen()
      )
    );
  }

  _toggleIsLogged(val) {
    setState(() {
      isLogged = val;
    });
  }
}