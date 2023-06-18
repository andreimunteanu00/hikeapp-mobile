import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/hike_history.dart';
import 'package:hikeappmobile/screen/no_hike_ongoing.screen.dart';

import '../service/hike_history.service.dart';
import '../util/constants.dart' as constants;

class FinishHikeScreen extends StatefulWidget {
  final String? hikeTitle;
  final double? temperatureAverage;
  final Function(Widget)? handleOnGoingHike;

  const FinishHikeScreen({
    super.key,
    this.temperatureAverage,
    this.hikeTitle,
    this.handleOnGoingHike
  });

  @override
  FinishHikeScreenState createState() => FinishHikeScreenState();
}

class FinishHikeScreenState extends State<FinishHikeScreen> {
  final HikeHistoryService hikeHistoryService = HikeHistoryService.instance;

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(constants.appTitle),
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
          child: Center(
              child: FutureBuilder(
                  future: hikeHistoryService.getLastHikeHistory(widget.hikeTitle!),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      HikeHistory hikeHistory = snapshot.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Summary', style: TextStyle(fontSize: 32, color: Colors.white)),
                          const SizedBox(height: 32),
                          Text(
                            hikeHistory.hike!.title!,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, color: Colors.white),
                              const SizedBox(width: 8.0),
                              Text(formatDuration(hikeHistory.elapsedTime!),
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.point_of_sale, color: Colors.white),
                              const SizedBox(width: 8.0),
                              Text(hikeHistory.hikePoints!.toStringAsFixed(2),
                              style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.thermostat_outlined, color: Colors.white),
                              const SizedBox(width: 8.0),
                              Text("${widget.temperatureAverage} °C",
                              style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: () {
                                widget.handleOnGoingHike!(
                                    const NoHikeOngoingScreen());
                              },
                              child: const Text('Finish'))
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  })),
        ),
      ])
    );
  }
}
