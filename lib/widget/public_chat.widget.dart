import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/picture.model.dart';
import 'package:hikeappmobile/screen/chat.screen.dart';
import 'package:hikeappmobile/util/enum/chat_type.enum.dart';
import 'package:hikeappmobile/widget/avatar.widget.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/chat_room.model.dart';
import '../model/user.model.dart';
import '../service/chat_room.service.dart';
import '../service/user.service.dart';
import '../util/constants.dart' as constants;
import '../util/methods.dart';

class PublicChatWidget extends StatefulWidget {

  @override
  PublicChatWidgetState createState() => PublicChatWidgetState();
}

class PublicChatWidgetState extends State<PublicChatWidget> {
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

  Future<void> _loadEntities() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      try {
        final entities = await userService.getAllEntities(
            username: _searchTerm,
            page: _page,
            size: _pageSize);
        final googleId = await Methods.giveGoogleIdFromToken();
        entities.removeWhere((entity) => entity.googleId! == googleId);
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
      _checkedValues.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Column(children: [
        TextField(
        controller: groupNameController,
        decoration:
          InputDecoration(
            labelText: 'Enter chat group name'
          ),
        ),
        SizedBox(height: 20),
        AvatarWidget(publicChatPhoto),
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
        Expanded(
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
        SizedBox(height: screenHeight / 100),
        ElevatedButton(onPressed: () async {
          String name = groupNameController.text;
          List<String> googleIds = [];
          googleIds.add(await Methods.giveGoogleIdFromToken());
          _checkedValues.asMap().forEach((index, e) {
            if (e == true) {
              googleIds.add(_entities[index].googleId!);
            }
          });
          ChatRoom chatRoom = await chatRoomService.createOrGetChatRoom(googleIds, name, publicChatPhoto, ChatType.public);
          Navigator.pop(context);
          setState(() {});
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ChatScreen(token: await Methods.getToken(), chatRoom: chatRoom),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.fade,
          );
        }, child: const Text('next'))
      ]),
    );
  }

}