import 'package:flutter/material.dart';

class UnratingModal extends StatefulWidget {
  @override
  UnratingModalState createState() => UnratingModalState();
}

class UnratingModalState extends State<UnratingModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Unrating'),
      content: const Text('Are you sure you want to unrate this hike?'),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          child: const Text('Unrate'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
