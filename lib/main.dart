import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/hike_list.screen.dart';
import 'package:hikeappmobile/screen/home.screen.dart';
import 'package:hikeappmobile/screen/home_logged.screen.dart';
import 'package:hikeappmobile/screen/log_in_screen.dart';
import 'package:hikeappmobile/screen/settings.screen.dart';
import 'package:hikeappmobile/service/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './util/routes.dart';
import 'model/user.model.dart';

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
  late bool afterFirstLogIn = false;

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
      } else {
        User user = await authService.getCurrentUser();
        setState(() {
          afterFirstLogIn = isLogged && !user.firstLogin! && user.active!;
        });
      }
    }
  }

  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const HikeListScreen(),
    const HomeLoggedScreen(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike App'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: !isLogged ? const LogInScreen() : (afterFirstLogIn ? _widgetOptions[_selectedIndex] : HomeScreen())
      ),
      bottomNavigationBar: afterFirstLogIn ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildNavItem(Icons.account_balance, 0),
              _buildNavItem(Icons.home, 1),
              _buildNavItem(Icons.settings, 2),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, color: _selectedIndex == index ? Colors.blue : Colors.grey),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  _toggleIsLogged(val) {
    setState(() {
      isLogged = val;
    });
  }
}