import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user.model.dart';
import '../util/methods.dart';

class AvatarWidget extends StatefulWidget {

  final User? user;

  const AvatarWidget(this.user, {super.key});
  @override
  AvatarWidgetState createState() => AvatarWidgetState();
}

class AvatarWidgetState extends State<AvatarWidget> {
  File _image = File('images/default_avatar.png');
  final picker = ImagePicker();

  Future getImage(User user) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        widget.user?.profilePicture = Methods.fileToBase64(_image);
      }
    });
  }

  giveBackgroundImage() {
    return widget.user!.profilePicture == null ? FileImage(_image) : MemoryImage(base64Decode(widget.user!.profilePicture!));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getImage(widget.user!);
      },
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green.shade300,
            width: 2.0,
          ),
        ),
        child: CircleAvatar(
          backgroundImage: giveBackgroundImage(),
        ),
      ),
    );
  }
}