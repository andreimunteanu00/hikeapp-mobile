import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/chat_room.model.dart';
import 'package:hikeappmobile/screen/chat.screen.dart';
import 'package:hikeappmobile/service/chat_room.service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
        title: Text('WhatsApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: chatRoomService.getCurrentUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            chatRooms = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      if (chatRooms[index].name == null) {
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
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                    backgroundImage: MemoryImage(base64Decode(chatRooms[index].receiver!.profilePicture!.base64!))
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  chatRooms[index].receiver!.username!,
                                  style: TextStyle(fontSize: 16.0),
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
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                    backgroundImage: MemoryImage(base64Decode(chatRooms[index].publicChatPhoto!.base64!))
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  chatRooms[index].name!,
                                  style: TextStyle(fontSize: 16.0),
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