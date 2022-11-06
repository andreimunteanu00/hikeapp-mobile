import 'package:flutter/material.dart';

import 'screen/authentication_screen.dart';
import 'screen/loading_screen.dart';
import 'screen/main_screen.dart';
import 'service/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isProgressing = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    initAuth();
    super.initState();
  }

  initAuth() async {
    setLoadingState();
    final bool isAuthenticated = await AuthService.instance.initAuth();
    if (isAuthenticated) {
      setAuthenticatedState();
    } else {
      setUnauthenticatedState();
    }
  }

  setLoadingState() {
    setState(() {
      isProgressing = true;
    });
  }

  setAuthenticatedState() {
    setState(() {
      isProgressing = false;
      isLoggedIn = true;
    });
  }

  setUnauthenticatedState() {
    setState(() {
      isProgressing = false;
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (context) {
          if (isProgressing) {
            return const LoadingScreen();
          } else if (isLoggedIn) {
            return MainScreen(
              setUnauthenticatedState: setUnauthenticatedState,
            );
          } else {
            return AuthenticationScreen(
              setLoadingState: setLoadingState,
              setAuthenticatedState: setAuthenticatedState,
              setUnauthenticatedState: setUnauthenticatedState,
            );
          }
        },
      ),
    );
  }
}
