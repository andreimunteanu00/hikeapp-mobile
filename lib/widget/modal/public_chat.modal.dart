import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/picture.model.dart';
import 'package:hikeappmobile/util/colors.dart';
import 'package:hikeappmobile/util/enum/chat_type.enum.dart';
import 'package:hikeappmobile/widget/avatar.widget.dart';

import '../../model/user.model.dart';
import '../../service/chat_room.service.dart';
import '../../service/user.service.dart';
import '../../util/constants.dart' as constants;
import '../../util/methods.dart';

class PublicChatModal extends StatefulWidget {

  @override
  PublicChatModalState createState() => PublicChatModalState();
}

class PublicChatModalState extends State<PublicChatModal> {
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
      checkedValues.clear();
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
        AvatarWidget(publicChatPhoto),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                  labelText: 'Enter chat group name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: background,
                      width: 1.0,
                    ),
                  ))
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    // Add a clear button to the search bar
                    suffixIcon: !searchTerm.isEmpty ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchTerm = '';
                          resetEntities();
                        }
                    ) : null,
                    // Add a search icon or button to the search bar
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        resetEntities();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: (value) {
                    searchTerm = value;
                    if (searchTerm.isEmpty) {
                      resetEntities();
                    }
                  },
                ),
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
        SizedBox(height: screenHeight / 100),
        ElevatedButton(onPressed: () async {
          String name = groupNameController.text;
          List<String> googleIds = [];
          googleIds.add(await Methods.giveGoogleIdFromToken());
          checkedValues.asMap().forEach((index, e) {
            if (e == true) {
              googleIds.add(userList[index].googleId!);
            }
          });
          await chatRoomService.createOrGetChatRoom(googleIds, name, publicChatPhoto, ChatType.public);
          Navigator.pop(context);
          setState(() {});
        }, child: const Text('CREATE'))
      ]),
    );
  }

}