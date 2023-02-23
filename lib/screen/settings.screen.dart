import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Option 1'),
          subtitle: Text('Description of option 1'),
          trailing: Switch(value: true, onChanged: (bool value) {}),
        ),
        ListTile(
          title: Text('Option 2'),
          subtitle: Text('Description of option 2'),
          trailing: Switch(value: false, onChanged: (bool value) {}),
        ),
        ListTile(
          title: Text('Option 3'),
          subtitle: Text('Description of option 3'),
          trailing: Switch(value: true, onChanged: (bool value) {}),
        ),
        ListTile(
          title: Text('Option 4'),
          subtitle: Text('Description of option 4'),
          trailing: Switch(value: false, onChanged: (bool value) {}),
        ),
        ListTile(
          title: Text('Option 5'),
          subtitle: Text('Description of option 5'),
          trailing: Switch(value: true, onChanged: (bool value) {}),
        ),
        ListTile(
          title: Text('Option 6'),
          subtitle: Text('Description of option 6'),
          trailing: Switch(value: false, onChanged: (bool value) {}),
        ),
      ],
    );
  }
}