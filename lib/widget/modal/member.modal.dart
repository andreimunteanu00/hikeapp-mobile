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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<User> _entities = [];
  final List<bool> _checkedValues = [];
  final int _pageSize = 10;
  String _searchTerm = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  String groupName = '';
  Picture publicChatPhoto = Picture();
  final groupNameController = TextEditingController();
  late List<User?> members;

  Future<void> _loadEntities() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      try {
        final entities = await userService.getAllEntities(
            username: _searchTerm,
            page: _page,
            size: _pageSize);
        final googleId = await Methods.giveGoogleIdFromToken();
        List<String> membersString = [];
        for (var element in widget.members) {
          membersString.add(element!.username!);
        }
        entities.removeWhere((entity) => entity.googleId! == googleId);
        widget.members.removeWhere((entity) => entity!.googleId! == googleId);
        entities.removeWhere((entity) => membersString.contains(entity.username));
        setState(() {
          _entities.addAll(entities);
          _checkedValues.addAll(List.filled(entities.length, false));
          _page++;
          _isLoading = false;
          _hasMore = entities.length == _pageSize;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(constants.failedToLoadData)));
      }
    }
  }

  void _resetEntities() {
    setState(() {
      _entities.clear();
      _page = 0;
      _hasMore = true;
    });
    _loadEntities();
  }

  @override
  void initState() {
    super.initState();
    _loadEntities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadEntities();
      }
    });
    members = widget.members;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: Text('Select Chat Type'),
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
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: MemoryImage(base64Decode(entity.profilePicture!.base64!)),
                            ),
                            title: Text(
                              entity.username!,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    })),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Add new member'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration:
                    const InputDecoration(hintText: 'Search by username'),
                    onChanged: (value) {
                      _searchTerm = value;
                      if (_searchTerm.isEmpty) {
                        _resetEntities();
                      }
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      _resetEntities();
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
                    controller: _scrollController,
                    itemCount: _entities.length + (_hasMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _entities.length) {
                        return _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox();
                      }
                      final User entity = _entities[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: CheckboxListTile(
                          secondary: CircleAvatar(
                            radius: 24,
                            backgroundImage: MemoryImage(base64Decode(entity.profilePicture!.base64!)),
                          ),
                          title: Text(
                            entity.username!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _checkedValues[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _checkedValues[index] = value!;
                            });
                          },
                        ),
                      );
                    })),
          ),
          SizedBox(height: screenHeight / 100),
          ElevatedButton(onPressed: () async {
            List<String> googleIds = [];
            _checkedValues.asMap().forEach((index, e) {
              if (e == true) {
                googleIds.add(_entities[index].googleId!);
              }
            });
            await chatRoomService.addMembers(googleIds, widget.groupId);
            _checkedValues.asMap().forEach((index, e) {
              if (e == true) {
                members.add(_entities[index]);
              }
            });
            setState(() {});
          }, child: const Text('add'))
        ]),
      )
    );
  }

}