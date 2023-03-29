import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/chat.screen.dart';
import 'package:hikeappmobile/util/enum/chat_type.enum.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/chat_room.model.dart';
import '../model/user.model.dart';
import '../service/chat_room.service.dart';
import '../service/user.service.dart';
import '../util/constants.dart' as constants;
import '../util/methods.dart';

class PrivateChatWidget extends StatefulWidget {

  @override
  PrivateChatWidgetState createState() => PrivateChatWidgetState();
}

class PrivateChatWidgetState extends State<PrivateChatWidget> {
  final UserService userService = UserService.instance;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<User> _entities = [];
  final int _pageSize = 10;
  String _searchTerm = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Column(children: [
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
                  return GestureDetector(
                    onTap: () async {
                      List<String> googleIds = [];
                      googleIds.add(await Methods.giveGoogleIdFromToken());
                      googleIds.add(entity.googleId!);
                      await chatRoomService.createOrGetChatRoom(googleIds, null, null, ChatType.private);
                      Navigator.pop(context);
                      setState(() {});
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
        SizedBox(height: screenHeight / 100),
      ]),
    );
  }

}