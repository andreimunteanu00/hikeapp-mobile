import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/main.dart';
import 'package:hikeappmobile/screen/history_screen.dart';
import 'package:hikeappmobile/widget/avatar.widget.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/user.model.dart';
import '../service/auth.service.dart';
import '../util/colors.dart';
import '../util/constants.dart' as constants;
import 'first_login.screen.dart';

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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(constants.appTitle),
        actions: [SignOutWidget()],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SingleChildScrollView(
              child: Column(
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
                              Text(
                                "Welcome back, ${snapshot.data!.username!}",
                                style: const TextStyle(
                                  fontSize: 24, // Replace with your desired font size
                                  color: primary,
                                ),
                              ),
                              SizedBox(height: screenHeight / 50),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AvatarWidget(snapshot.data!.profilePicture!, readOnly: true),
                                ],
                              ),
                              SizedBox(height: screenHeight / 30),/*
                              Text("Hike points: ${snapshot.data!.hikePoints?.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18, // Replace with your desired font size
                                    color: accent,
                                  )),
                              SizedBox(height: screenHeight / 25),*/
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: screenWidth / 3.75,
                                    height: screenWidth / 3.75,
                                    child: ElevatedButton(
                                      onPressed: () => widget.controller.jumpToTab(1),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Discovery',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.search)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth / 15),
                                  SizedBox(
                                    width: screenWidth / 3.75, // Replace with your desired width
                                    height: screenWidth / 3.75, // Replace with your desired height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: HikeHistoryScreen(controller: widget.controller, handleOnGoingHike: widget.handleOnGoingHike),
                                          withNavBar: true,
                                          pageTransitionAnimation: PageTransitionAnimation.fade,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'History',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.history)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth / 15),
                                  SizedBox(
                                    width: screenWidth / 3.75, // Replace with your desired width
                                    height: screenWidth / 3.75, // Replace with your desired height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: FirstLoginScreen(fromSetup: false),
                                          withNavBar: true,
                                          pageTransitionAnimation: PageTransitionAnimation.fade,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Settings',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.settings)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25),
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                      child: Text(
                                        'Exciting New Hiking Trails!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Discover breathtaking new hiking trails that have just been opened in your area. These trails offer stunning views, diverse terrains, and unique experiences for all hiking enthusiasts.\n\nLace up your boots and embark on an adventure through nature like never before!\n\nStay tuned for a breathtaking journey through nature\'s wonders, where rugged landscapes meet hidden treasures.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}