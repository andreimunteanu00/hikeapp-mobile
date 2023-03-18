import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoHikeOngoingScreen extends StatelessWidget {
  const NoHikeOngoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike'),
      ),
      body: const Center(child: Text('no hike ongoing!')),
    );
  }
}
