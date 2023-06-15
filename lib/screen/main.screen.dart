import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/no_hike_ongoing.screen.dart';
import 'package:hikeappmobile/screen/chat_room_list.screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'dart:ui';

import 'hike_list.screen.dart';
import 'home.screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  void handleOnGoingHike(Widget screen) {
    setState(() {
      buildScreens[buildScreens.length - 1] = screen;
    });
  }

  List<Widget> buildScreens = [];

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.white,
        inactiveColorPrimary: CupertinoColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.search_circle),
        title: ("Discover"),
        activeColorPrimary: CupertinoColors.white,
        inactiveColorPrimary: CupertinoColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.chat_bubble),
        title: ("Chat"),
        activeColorPrimary: CupertinoColors.white,
        inactiveColorPrimary: CupertinoColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.star_circle),
        title: ("Ongoing Hike"),
        activeColorPrimary: CupertinoColors.white,
        inactiveColorPrimary: CupertinoColors.white,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    buildScreens = [
      HomeScreen(controller: controller, handleOnGoingHike: handleOnGoingHike),
      HikeListScreen(controller: controller, handleOnGoingHike: handleOnGoingHike),
      ChatRoomListScreen(),
      const NoHikeOngoingScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust the opacity as needed
            ),
          ),
          PersistentTabView(
            context,
            controller: controller,
            screens: buildScreens,
            items: navBarsItems(),
            confineInSafeArea: true,
            backgroundColor: Colors.transparent,
            handleAndroidBackButtonPress: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardShows: true,
            popAllScreensOnTapOfSelectedTab: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: const ItemAnimationProperties(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: const ScreenTransitionAnimation(
              animateTabTransition: true,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle.style1,
          ),
        ],
      ),
    );
  }
}
