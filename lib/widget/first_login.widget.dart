import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/user.service.dart';

import '../model/user.model.dart';

class FirstLoginWidget extends StatefulWidget {

  final User user;
  final UserService userService = new UserService();

  FirstLoginWidget(this.user, {super.key});

  @override
  FirstLoginState createState() => FirstLoginState();
}

class FirstLoginState extends State<FirstLoginWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
            onSaved: (value) => widget.user.username = value,
          ),
          /*TextFormField(
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
            onSaved: (value) => widget.user.firstName = value,
          ),*/
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  await widget.userService.saveUserData(widget.user);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved')));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}