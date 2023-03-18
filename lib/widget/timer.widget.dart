import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Elapsed Time:',
          style: TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hoursElapsed:',
              style: const TextStyle(fontSize: 32.0),
            ),
            Text(
              '${minutesElapsed.toString().padLeft(2, '0')}:',
              style: const TextStyle(fontSize: 32.0),
            ),
            Text(
              secondsElapsed.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 32.0),
            ),
          ],
        ),
      ],
    );
  }
}
