import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/chat_room.model.dart';
import 'package:hikeappmobile/screen/chat.screen.dart';
import 'package:hikeappmobile/service/chat_room.service.dart';
import 'package:hikeappmobile/service/websocket.service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../model/chat_message.model.dart';
import '../util/constants.dart' as constants;
import '../util/methods.dart';
import '../widget/modal/private_chat.modal.dart';
import '../widget/modal/public_chat.modal.dart';

class ChatRoomListScreen extends StatefulWidget {

  late final String token;

  @override
  ChatRoomListScreenState createState() => ChatRoomListScreenState();
}

class ChatRoomListScreenState extends State<ChatRoomListScreen> {

  List<ChatRoom> chatRooms = [];
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  Map<int, ChatMessage?> lastMessages = {};
  List<WebSocketService> wbsList = [];

  void _showChatTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Select Chat Type')),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the boxes horizontally
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: PrivateChatModal(),
                          );
                        },
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.lock),
                          SizedBox(width: 8),
                          Text('Private'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Add spacing between the boxes
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: PublicChatModal(),
                          );
                        },
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.public),
                          SizedBox(width: 8),
                          Text('Public'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  getTokenMethod() async {
    String aux1 = await Methods.getToken();
    setState(() {
      widget.token = aux1;
    });
  }

  String compressMessage(String message) {
    if (message.length <= 30) {
      return message;
    } else {
      return '${message.substring(0, 27)}...';
    }
  }

  void toggleMessages(ChatMessage message) {
    setState(() {
      lastMessages[message.chatRoomId!] = message;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTokenMethod();
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (var wbs in wbsList) {
      wbs.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(constants.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: FutureBuilder<List<ChatRoom>>(
              future: chatRoomService.getCurrentUserChatRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  chatRooms = snapshot.data!;
                  chatRooms.sort((a, b) {
                    if (a.lastMessage == null) {
                      return 1;
                    } else if (b.lastMessage == null) {
                      return -1;
                    } else {
                      return -(a.lastMessage!.timestamp ?? DateTime(0)).compareTo(b.lastMessage!.timestamp ?? DateTime(0));
                    }
                  });
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            lastMessages[chatRooms[index].id!] = chatRooms[index].lastMessage != null ? chatRooms[index].lastMessage! : null;
                            WebSocketService wbs = WebSocketService(token: widget.token, toggleMessages: toggleMessages, chatRoomId: chatRooms[index].id!);
                            wbs.connect(widget.token);
                            wbsList.add(wbs);
                            if (chatRooms[index].name == null) {
                              return GestureDetector(
                                onTap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: ChatScreen(token: widget.token, chatRoom: chatRooms[index]),
                                    withNavBar: true,
                                    pageTransitionAnimation: PageTransitionAnimation.fade,
                                  );
                                },
                                child: Card(
                                color: const Color.fromRGBO(96, 137, 110, 0.5),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 75, height: 75, child: CircleAvatar(
                                            backgroundImage: MemoryImage(base64Decode(chatRooms[index].receiver!.profilePicture!.base64!))
                                        )),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                chatRooms[index].receiver!.username!,
                                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                lastMessages[wbs.chatRoomId] != null
                                                    ? compressMessage(lastMessages[wbs.chatRoomId]!.content!)
                                                    : 'Not yet',
                                                style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                      Text(
                                        lastMessages[wbs.chatRoomId] != null
                                            ? time_ago.format(lastMessages[wbs.chatRoomId]!.timestamp!)
                                            : '',
                                        style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: ChatScreen(token: widget.token, chatRoom: chatRooms[index]),
                                    withNavBar: true,
                                    pageTransitionAnimation:
                                    PageTransitionAnimation.fade,
                                  ).then((value) {
                                    setState(() {

                                    });
                                  });
                                },
                                child: Card(
                                color: const Color.fromRGBO(96, 137, 110, 0.5),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 75, height: 75, child: CircleAvatar(
                                            backgroundImage: MemoryImage(base64Decode(chatRooms[index].publicChatPhoto!.base64!))
                                        )),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                chatRooms[index].name!,
                                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                lastMessages[wbs.chatRoomId] != null
                                                    ? '${lastMessages[wbs.chatRoomId]!.sender!}: ${compressMessage(lastMessages[wbs.chatRoomId]!.content!)}'
                                                    : 'Not yet',
                                                style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Text(
                                          lastMessages[wbs.chatRoomId] != null
                                              ? time_ago.format(lastMessages[wbs.chatRoomId]!.timestamp!)
                                              : '',
                                          style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          _showChatTypeDialog();
        },
      ),
    );
  }
}