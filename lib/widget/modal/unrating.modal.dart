import 'package:flutter/material.dart';

class UnratingModal extends StatefulWidget {
  @override
  _UnratingModalState createState() => _UnratingModalState();
}

class _UnratingModalState extends State<UnratingModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Unrating'),
      content: Text('Are you sure you want to unrate this hike?'),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          child: Text('Unrate'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}