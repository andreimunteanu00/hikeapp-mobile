import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/no_hike_ongoing.screen.dart';
import 'package:hikeappmobile/screen/chat_room_list.screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.search_circle),
        title: ("Discover"),
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.chat_bubble),
        title: ("Chat"),
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.star_circle),
        title: ("Ongoing Hike"),
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    buildScreens = [
      const HomeScreen(),
      HikeListScreen(controller: controller, handleOnGoingHike: handleOnGoingHike),
      ChatRoomListScreen(),
      const NoHikeOngoingScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      screens: buildScreens,
      items: navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style2,
    );
  }
}
