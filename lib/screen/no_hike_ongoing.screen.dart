import 'dart:ui';

import 'package:flutter/material.dart';

class NoHikeOngoingScreen extends StatelessWidget {
  const NoHikeOngoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike'),
      ),
      body: Stack(children: [
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
            child: const Center(child: Text('No hike ongoing!', style: TextStyle(fontSize: 24, color: Colors.white)))
        )
      ]),
    );
  }
}
