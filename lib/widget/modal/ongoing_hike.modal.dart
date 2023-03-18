import 'package:flutter/material.dart';

class OngoingHikeModal extends StatelessWidget {
  const OngoingHikeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('Hike already ongoing!'),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
