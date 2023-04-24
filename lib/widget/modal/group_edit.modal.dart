import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/picture.model.dart';
import 'package:hikeappmobile/service/chat_room.service.dart';
import 'package:hikeappmobile/widget/avatar.widget.dart';

class GroupEditModal extends StatefulWidget {
  final int? groupId;
  final String? groupName;
  final Picture? groupPhoto;

  const GroupEditModal({Key? key, this.groupName, this.groupPhoto, this.groupId}) : super(key: key);

  @override
  GroupEditModalState createState() => GroupEditModalState();
}

class GroupEditModalState extends State<GroupEditModal> {
  late TextEditingController nameController;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  late Picture newPhoto;

  @override
  void initState() {
    super.initState();
    nameController =  TextEditingController(text: widget.groupName);
    newPhoto = widget.groupPhoto!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit group info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
            ),
          ),
          const SizedBox(height: 16),
          AvatarWidget(newPhoto)
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await chatRoomService.editGroup(widget.groupId!, nameController.text, newPhoto);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}