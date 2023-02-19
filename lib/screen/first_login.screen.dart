import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/user.service.dart';
import 'package:hikeappmobile/widget/custom_text_form_field.widget.dart';

import '../main.dart';
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
  bool usernameCheckDuplicate = false;
  /*bool phoneCheckDuplicate = false;*/

  bool isPhoneNumberValid(String phoneNumber) {
    final RegExp phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    return phoneExp.hasMatch(phoneNumber);
  }

  String? usernameTextValidator(String? value) {
    if (value!.isEmpty) {
      return 'Username is required';
    }
    if (usernameCheckDuplicate == true) {
      return 'Username already exists';
    }
    return null;
  }

  /*String? phoneValidator(String? value) {
    if (value!.isEmpty) {
      return 'Phone number is required';
    }
    if (isPhoneNumberValid(value) == false) {
      return 'Phone number is invalid';
    }
    if (phoneCheckDuplicate == true) {
      return 'Phone number already exists';
    }
    return null;
  }*/

  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final formKeyUsername = GlobalKey<FormState>();
    /*final formKeyPhoneNumber = GlobalKey<FormState>();*/
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AvatarWidget(widget.user),
            SizedBox(height: screenWidth / 20),
            Focus(
              child: Form(
                key: formKeyUsername,
                child: CustomTextFormField(
                  key: const Key('formKeyUsername'),
                  readOnly: false,
                  initialValue: widget.user.username,
                  labelWidth: screenWidth - screenWidth / 4,
                  keyboardType: TextInputType.text,
                  labelText: 'Username',
                  validator: usernameTextValidator,
                  onChange: (value) {
                    widget.user.username = value;
                  },
                ),
              ),
              onFocusChange: (hasFocus) async {
                if (!hasFocus) {
                  usernameCheckDuplicate = await widget.userService.checkFieldDuplicate('username', widget.user.username);
                  formKeyUsername.currentState!.validate();
                }
              },
            ),
            SizedBox(height: screenWidth / 20),
            /*Focus(
            child: Form(
              key: formKeyPhoneNumber,
              child: CustomTextFormField(
                  readOnly: false,
                  key: const Key('formKeyPhoneNumber'),
                  initialValue: widget.user.phoneNumber,
                  labelWidth: screenWidth - screenWidth / 4,
                  keyboardType: TextInputType.number,
                  labelText: 'Phone number',
                  validator: phoneValidator,
                  onChange: (value) {
                    widget.user.phoneNumber = value;
                  }
              ),
            ),
            onFocusChange: (hasFocus) async {
              if (!hasFocus) {
                phoneCheckDuplicate = await widget.userService.checkFieldDuplicate('phone_number', widget.user.phoneNumber);
                formKeyPhoneNumber.currentState!.validate();
              }
            },
          ),*/
            /*SizedBox(height: screenWidth / 20),*/
            CustomTextFormField(
                readOnly: true,
                initialValue: widget.user.email,
                labelWidth: screenWidth - screenWidth / 4,
                keyboardType: TextInputType.text,
                labelText: 'Email',
                onChange: (value) {
                  widget.user.email = value;
                }
            ),
            SizedBox(height: screenWidth / 10),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  try {
                    widget.user.firstLogin = false;
                    await widget.userService.saveUserData(widget.user);
                    Navigator.pushNamed(navigatorKey.currentContext!, '/home');
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
              child: const Text('Finish setup'),
            )
          ],
        ),
      )
    );
  }
}