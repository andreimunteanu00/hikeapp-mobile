import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/history_screen.dart';
import 'package:hikeappmobile/widget/avatar.widget.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import '../util/constants.dart' as constants;

class HomeScreen extends StatefulWidget {
  final PersistentTabController controller;
  final Function(Widget) handleOnGoingHike;

  const HomeScreen({super.key, required this.controller, required this.handleOnGoingHike});

  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User? currentUser;
  final AuthService authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    final user = await authService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text(constants.appTitle)),
      body: Column(
        children: [
          FutureBuilder<User>(
              future: authService.getCurrentUser(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight / 20),
                          Text("Welcome back, ${snapshot.data!.username!}"),
                          SizedBox(height: screenHeight / 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => widget.controller.jumpToTab(1),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Discovery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              AvatarWidget(snapshot.data!.profilePicture!, readOnly: true),
                              ElevatedButton(
                                onPressed: () => {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: HikeHistoryScreen(controller: widget.controller, handleOnGoingHike: widget.handleOnGoingHike),
                                    withNavBar: true,
                                    pageTransitionAnimation:
                                    PageTransitionAnimation.fade,
                                  )
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'History',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text("Hike points: ${snapshot.data!.hikePoints}")
                        ],
                  ));
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }),
          SignOutWidget()
        ],
      ),
    );
  }
}