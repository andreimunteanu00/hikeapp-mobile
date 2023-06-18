import 'package:flutter/material.dart';
import 'package:hikeappmobile/util/colors.dart';

class TimerWidget extends StatelessWidget {
  final int? secondsElapsed;
  final int? minutesElapsed;
  final int? hoursElapsed;

  const TimerWidget({
    super.key,
    this.secondsElapsed,
    this.minutesElapsed,
    this.hoursElapsed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8.0),
        const Icon(
          Icons.timer,
          size: 24.0,
          color: primary,
        ),
        const SizedBox(width: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hoursElapsed:',
              style: const TextStyle(fontSize: 32.0, color: primary),
            ),
            Text(
              '${minutesElapsed.toString().padLeft(2, '0')}:',
              style: const TextStyle(fontSize: 32.0, color: primary),
            ),
            Text(
              secondsElapsed.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 32.0, color: primary),
            ),
          ],
        ),
      ],
    );
  }
}
