import 'dart:convert';

import 'package:flutter/material.dart';

import '../../model/picture.model.dart';
import '../../model/user.model.dart';
import '../../service/chat_room.service.dart';
import '../../service/user.service.dart';
import '../../util/constants.dart' as constants;
import '../../util/methods.dart';

class MemberModal extends StatefulWidget {
  final int groupId;
  final List<User?> members;

  const MemberModal({super.key, required this.members, required this.groupId});

  @override
  MemberModalState createState() => MemberModalState();
}

class MemberModalState extends State<MemberModal> {
  final UserService userService = UserService.instance;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<User> userList = [];
  final List<bool> checkedValues = [];
  final int pageSize = 10;
  String searchTerm = '';
  bool isLoading = false;
  bool hasMore = true;
  int page = 0;
  String groupName = '';
  Picture publicChatPhoto = Picture();
  final groupNameController = TextEditingController();
  late List<User?> members;

  Future<void> fetchData() async {
    if (!isLoading && hasMore) {
      setState(() => isLoading = true);
      try {
        final entities = await userService.getAllEntities(
            username: searchTerm,
            page: page,
            size: pageSize);
        final googleId = await Methods.giveGoogleIdFromToken();
        List<String> membersString = [];
        for (var element in widget.members) {
          membersString.add(element!.username!);
        }
        entities.removeWhere((entity) => entity.googleId! == googleId);
        widget.members.removeWhere((entity) => entity!.googleId! == googleId);
        entities.removeWhere((entity) => membersString.contains(entity.username));
        setState(() {
          userList.addAll(entities);
          checkedValues.addAll(List.filled(entities.length, false));
          page++;
          isLoading = false;
          hasMore = entities.length == pageSize;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(constants.failedToLoadData)));
      }
    }
  }

  void resetEntities() {
    setState(() {
      userList.clear();
      page = 0;
      hasMore = true;
    });
    fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetchData();
      }
    });
    members = widget.members;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: const Text('Select Chat Type'),
      content: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(children: [
          SizedBox(
            width: screenWidth,
            height: screenHeight / 4,
            child: Expanded(
                child: ListView.builder(
                    controller: null,
                    itemCount: members.length,
                    itemBuilder: (BuildContext context, int index) {
                      final User entity = members[index]!;
                      return GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: const Text('Actions'),
                                children: <Widget>[
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      await chatRoomService.removeMember(entity.googleId!, widget.groupId);
                                      members.removeWhere((element) => element!.googleId == entity.googleId!);
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Remove member'),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      await chatRoomService.giveAdmin(entity.googleId!, widget.groupId);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Give admin'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: MemoryImage(base64Decode(entity.profilePicture!.base64!)),
                            ),
                            title: Text(
                              entity.username!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    })),
          ),
          const Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Add new member'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration:
                    const InputDecoration(hintText: 'Search by username'),
                    onChanged: (value) {
                      searchTerm = value;
                      if (searchTerm.isEmpty) {
                        resetEntities();
                      }
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      resetEntities();
                    },
                    child: const Icon(Icons.search)
                )
              ],
            ),
          ),
          SizedBox(
            width: screenWidth,
            height: screenHeight / 4 + screenHeight / 20,
            child: Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: userList.length + (hasMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == userList.length) {
                        return isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox();
                      }
                      final User entity = userList[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: CheckboxListTile(
                          secondary: CircleAvatar(
                            radius: 24,
                            backgroundImage: MemoryImage(base64Decode(entity.profilePicture!.base64!)),
                          ),
                          title: Text(
                            entity.username!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: checkedValues[index],
                          onChanged: (bool? value) {
                            setState(() {
                              checkedValues[index] = value!;
                            });
                          },
                        ),
                      );
                    })),
          ),
          SizedBox(height: screenHeight / 100),
          ElevatedButton(onPressed: () async {
            List<String> googleIds = [];
            checkedValues.asMap().forEach((index, e) {
              if (e == true) {
                googleIds.add(userList[index].googleId!);
              }
            });
            await chatRoomService.addMembers(googleIds, widget.groupId);
            checkedValues.asMap().forEach((index, e) {
              if (e == true) {
                members.add(userList[index]);
              }
            });
            setState(() {});
          }, child: const Text('add'))
        ]),
      )
    );
  }

}