import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/user.service.dart';
import 'package:hikeappmobile/widget/custom_text_form_field.widget.dart';

import '../main.dart';
import '../model/user.model.dart';
import '../util/singe_page_route.dart';
import 'avatar.widget.dart';
import 'sign_out.widget.dart';

class FirstLoginWidget extends StatefulWidget {
  final User user;
  final bool fromSetup;
  final UserService userService = UserService.instance;

  FirstLoginWidget(this.user, this.fromSetup, {super.key});

  @override
  FirstLoginState createState() => FirstLoginState();
}

class FirstLoginState extends State<FirstLoginWidget> {
  bool usernameCheckDuplicate = false;

  String? usernameTextValidator(String? value) {
    if (value!.isEmpty) {
      return 'Username is required';
    }
    if (value.contains(RegExp(r'\s'))) {
      return 'Username shouldn\'t have white spaces';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Username should only have letters and digits';
    }
    print(widget.fromSetup);
    if (widget.fromSetup == false) {
      print(widget.user.username);
      if (usernameCheckDuplicate == true && widget.user.username != value) {
        return 'Username already exists';
      }
    } else {
      if (usernameCheckDuplicate == true) {
        return 'Username already exists';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final formKeyUsername = GlobalKey<FormState>();
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
        child: Column(
        children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AvatarWidget(widget.user.profilePicture),
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
                    usernameCheckDuplicate = await widget.userService
                        .checkFieldDuplicate('username', widget.user.username);
                    formKeyUsername.currentState!.validate();
                  }
                },
              ),
              SizedBox(height: screenWidth / 20),
              CustomTextFormField(
                  readOnly: true,
                  initialValue: widget.user.email,
                  labelWidth: screenWidth - screenWidth / 4,
                  keyboardType: TextInputType.text,
                  labelText: 'Email',
                  onChange: (value) {
                    widget.user.email = value;
                  }),
              SizedBox(height: screenWidth / 10),
              ElevatedButton(
                onPressed: () async {
                  if (usernameCheckDuplicate == false) {
                    usernameCheckDuplicate = await widget.userService
                        .checkFieldDuplicate('username', widget.user.username);
                  }
                  if (formKeyUsername.currentState!.validate()) {
                    formKey.currentState!.save();
                    try {
                      widget.user.firstLogin = false;
                      await widget.userService.saveUserData(widget.user);
                      if (widget.fromSetup) {
                        Navigator.pushReplacement(
                          context,
                          SlidePageRoute(
                            widget: const Main(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Updated')));
                      }
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    }
                  }
                },
                child: widget.fromSetup ? const Text('Finish setup') : const Text('Update'),
              )
            ],
          ),
        ),
        widget.fromSetup ? SignOutWidget() : const SizedBox.shrink()
      ],
    ));
  }
}
