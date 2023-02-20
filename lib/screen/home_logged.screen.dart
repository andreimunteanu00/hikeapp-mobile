import 'package:flutter/material.dart';

import 'log_in_screen.dart';

class HomeLoggedScreen extends StatefulWidget {

  const HomeLoggedScreen({super.key});

  @override
  State createState() => HomeLoggedScreenState();

}

class HomeLoggedScreenState extends State<HomeLoggedScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const LogInScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Main content
          _children[_currentIndex],

          // Bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
