import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/chat_room.model.dart';
import 'package:hikeappmobile/screen/chat.screen.dart';
import 'package:hikeappmobile/service/chat_room.service.dart';
import 'package:hikeappmobile/service/websocket.service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../model/chat_message.model.dart';
import '../util/constants.dart' as constants;
import '../util/methods.dart';
import '../widget/private_chat.widget.dart';
import '../widget/public_chat.widget.dart';

class ChatRoomListScreen extends StatefulWidget {

  late final String token;

  @override
  ChatRoomListScreenState createState() => ChatRoomListScreenState();
}

class ChatRoomListScreenState extends State<ChatRoomListScreen> {

  List<ChatRoom> chatRooms = [];
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  Map<int, ChatMessage?> lastMessages = {};

  void _showChatTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Chat Type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Private Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('Select Chat Type'),
                            content: PrivateChatWidget()
                        );
                      }).then((value) {
                      setState(() {});
                    });
                  }
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                    child: Text('Public Chat'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text('Select Chat Type'),
                                content: PublicChatWidget()
                            );
                          }).then((value) {
                        setState(() {});
                      });
                    }
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _asyncMethod() async {
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
      _asyncMethod();
    });
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
      body: FutureBuilder<List<ChatRoom>>(
        future: chatRoomService.getCurrentUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            chatRooms = snapshot.data!;
            chatRooms.sort((a, b) {
              // Check if either ChatRoom has a null lastMessage
              if (a.lastMessage == null) {
                return 1; // Move a to the end of the list
              } else if (b.lastMessage == null) {
                return -1; // Move b to the end of the list
              } else {
                // Compare the timestamp fields of the lastMessage objects
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
                      if (chatRooms[index].name == null) {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: ChatScreen(token: widget.token, chatRoom: chatRooms[index]),
                                withNavBar: true,
                                pageTransitionAnimation:
                                PageTransitionAnimation.fade,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 75, height: 75, child: CircleAvatar(
                                    backgroundImage: MemoryImage(base64Decode(chatRooms[index].receiver!.profilePicture!.base64!))
                                )),
                                SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatRooms[index].receiver!.username!,
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        lastMessages[wbs.chatRoomId] != null
                                            ? '${compressMessage(lastMessages[wbs.chatRoomId]!.content!)}'
                                            : 'Not yet',
                                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  lastMessages[wbs.chatRoomId] != null
                                      ? timeAgo.format(lastMessages[wbs.chatRoomId]!.timestamp!)
                                      : '',
                                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GestureDetector(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 75, height: 75, child: CircleAvatar(
                                    backgroundImage: MemoryImage(base64Decode(chatRooms[index].publicChatPhoto!.base64!))
                                )),
                                SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatRooms[index].name!,
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        lastMessages[wbs.chatRoomId] != null
                                            ? '${lastMessages[wbs.chatRoomId]!.sender!}: ${compressMessage(lastMessages[wbs.chatRoomId]!.content!)}'
                                            : 'Not yet',
                                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  lastMessages[wbs.chatRoomId] != null
                                      ? timeAgo.format(lastMessages[wbs.chatRoomId]!.timestamp!)
                                      : '',
                                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                ),
                              ],
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          _showChatTypeDialog();
        },
      ),
    );
  }
}