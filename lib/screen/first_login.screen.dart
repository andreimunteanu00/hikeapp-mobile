import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/user.service.dart';
import 'package:hikeappmobile/widget/custom_text_form_field.widget.dart';

import '../model/user.model.dart';
import '../widget/avatar.widget.dart';

class FirstLoginScreen extends StatefulWidget {

  final User user;
  final UserService userService = UserService.instance;

  FirstLoginScreen(this.user, {super.key});

  @override
  FirstLoginState createState() => FirstLoginState();
}

class FirstLoginState extends State<FirstLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool usernameCheckDuplicate = false;
  bool phoneCheckDuplicate = false;
  String previousUsername = '';
  String previousPhoneNumber = '';

  bool _isPhoneNumberValid(String phoneNumber) {
    final RegExp phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    return phoneExp.hasMatch(phoneNumber);
  }

  String? _usernameTextValidator(String? value) {
    if (value!.isEmpty) {
      return 'Username is required';
    }
    if (usernameCheckDuplicate == true) {
      return 'Username already exists';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value!.isEmpty) {
      return 'Phone number is required';
    }
    if (_isPhoneNumberValid(value) == false) {
      return 'Phone number is invalid';
    }
    if (phoneCheckDuplicate == true) {
      return 'Phone number already exists';
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
          AvatarWidget(widget.user),
          SizedBox(height: screenWidth / 20),
          Focus(
            child: CustomTextFormField(
              enabled: true,
              initialValue: widget.user.username,
              labelWidth: screenWidth - screenWidth / 4,
              keyboardType: TextInputType.text,
              labelText: 'Username',
              validator: _usernameTextValidator,
              onChange: (value) async {
                widget.user.username = value;
              },
            ),
            onFocusChange: (hasFocus) async {
              if (previousUsername.isEmpty || previousUsername != widget.user.username!) {
                previousUsername = widget.user.username!;
                usernameCheckDuplicate = await widget.userService.checkFieldDuplicate('username', widget.user.username!);
              }
              _formKey.currentState!.validate();
            },
          ),
          SizedBox(height: screenWidth / 20),
          Focus(
            child: CustomTextFormField(
              enabled: true,
              initialValue: widget.user.phoneNumber,
              labelWidth: screenWidth - screenWidth / 4,
              keyboardType: TextInputType.number,
              labelText: 'Phone number',
              validator: _phoneValidator,
              onChange: (value) async {
                widget.user.phoneNumber = value;
              }
            ),
            onFocusChange: (hasFocus) async {
              if (hasFocus == false) {
                if (previousPhoneNumber.isEmpty || previousPhoneNumber != widget.user.phoneNumber!) {
                  previousPhoneNumber = widget.user.phoneNumber!;
                  phoneCheckDuplicate = await widget.userService.checkFieldDuplicate('phone_number', widget.user.phoneNumber!);
                }
                _formKey.currentState!.validate();
              }
            },
          ),
          SizedBox(height: screenWidth / 20),
          CustomTextFormField(
            enabled: false,
            initialValue: widget.user.email,
            labelWidth: screenWidth - screenWidth / 4,
            keyboardType: TextInputType.text,
            labelText: 'Email',
            onChange: (value) {
              widget.user.email = value;
            }
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
            child: const Text('Finish setup'),
          )
        ],
      ),
    );
  }
}