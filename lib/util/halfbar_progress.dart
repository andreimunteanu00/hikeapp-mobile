import 'dart:math';

import 'package:flutter/material.dart';

class HalfCircleProgressBar extends StatelessWidget {
  final double progress; // The progress value (between 0 and 1)
  final double strokeWidth; // The thickness of the progress bar
  final Color progressColor; // The color of the progress bar

  const HalfCircleProgressBar({super.key,
    required this.progress,
    this.strokeWidth = 8.0,
    this.progressColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: strokeWidth * 1.5, // Adjust the height based on the desired thickness
      child: CustomPaint(
        painter: _HalfCircleProgressBarPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          progressColor: progressColor,
        ),
      ),
    );
  }
}

class _HalfCircleProgressBarPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;

  _HalfCircleProgressBarPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final radius = (size.height - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw the background semi-circle
    final backgroundPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        pi,
      );

    canvas.drawPath(backgroundPath, progressPaint..color = Colors.grey);

    // Draw the progress semi-circle
    final progressPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        pi * progress,
      );

    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(_HalfCircleProgressBarPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        progressColor != oldDelegate.progressColor;
  }
}
