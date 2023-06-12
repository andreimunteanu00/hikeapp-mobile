import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/util/enum/chat_type.enum.dart';

import '../../model/user.model.dart';
import '../../service/chat_room.service.dart';
import '../../service/user.service.dart';
import '../../util/constants.dart' as constants;
import '../../util/methods.dart';

class PrivateChatModal extends StatefulWidget {

  @override
  PrivateChatModalState createState() => PrivateChatModalState();
}

class PrivateChatModalState extends State<PrivateChatModal> {
  final UserService userService = UserService.instance;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<User> userList = [];
  final int pageSize = 10;
  String searchTerm = '';
  bool isLoading = false;
  bool hasMore = true;
  int page = 0;

  Future<void> fetchData() async {
    if (!isLoading && hasMore) {
      setState(() => isLoading = true);
      try {
        final entities = await userService.getAllEntities(
            username: searchTerm,
            page: page,
            size: pageSize);
        final googleId = await Methods.giveGoogleIdFromToken();
        entities.removeWhere((entity) => entity.googleId! == googleId);
        setState(() {
          userList.addAll(entities);
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
        Expanded(
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
        SizedBox(height: screenHeight / 100),
      ]),
    );
  }

}