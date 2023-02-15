import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/user.service.dart';
import 'package:hikeappmobile/widget/custom_text_form_field.widget.dart';

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

  bool _isPhoneNumberValid(String phoneNumber) {
    final RegExp phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    return phoneExp.hasMatch(phoneNumber);
  }

  String? _usernameTextValidator(String? value) {
    if (value!.isEmpty) {
      return 'Username is required';
    }
  }

  String? _phoneValidator(String? value) {
    if (value!.isEmpty) {
      return 'Phone number is required';
    }
    if (_isPhoneNumberValid(value) == false) {
      return 'Phone number is invalid';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          CustomTextFormField(
            enabled: true,
            initialValue: widget.user.username,
            labelWidth: screenWidth - screenWidth / 4,
            keyboardType: TextInputType.text,
            labelText: 'Username',
            validator: _usernameTextValidator,
            onChange: (value) => {
              widget.user.username = value
            },
          ),
          SizedBox(height: screenWidth / 20),
          CustomTextFormField(
            enabled: true,
            initialValue: widget.user.phoneNumber,
            labelWidth: screenWidth - screenWidth / 4,
            keyboardType: TextInputType.number,
            labelText: 'Phone number',
            validator: _phoneValidator,
            onChange: (value) => {
              widget.user.phoneNumber = value
            }
          ),
          SizedBox(height: screenWidth / 20),
          CustomTextFormField(
            enabled: false,
            initialValue: widget.user.email,
            labelWidth: screenWidth - screenWidth / 4,
            keyboardType: TextInputType.text,
            labelText: 'Email',
            onChange: (value) => {
              widget.user.email = value
            },
          ),
          SizedBox(height: screenWidth / 5),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  widget.user.firstLogin = false;
                  await widget.userService.saveUserData(widget.user);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved')));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}