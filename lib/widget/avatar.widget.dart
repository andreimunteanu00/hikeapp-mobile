import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/picture.model.dart';
import '../util/methods.dart';

class AvatarWidget extends StatefulWidget {
  final Picture? picture;
  final bool readOnly;

  const AvatarWidget(this.picture, {super.key, this.readOnly = false});

  @override
  AvatarWidgetState createState() => AvatarWidgetState();
}

class AvatarWidgetState extends State<AvatarWidget> {
  File _image = File('/images/default_avatar.png');
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        widget.picture!.base64 = Methods.fileToBase64(_image);
      }
    });
  }

  giveBackgroundImage() {
    return widget.picture!.base64 == null
        ? FileImage(_image)
        : MemoryImage(base64Decode(widget.picture!.base64!));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(!widget.readOnly) getImage();
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
