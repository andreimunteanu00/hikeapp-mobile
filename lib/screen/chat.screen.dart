import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/chat_message.service.dart';
import 'package:hikeappmobile/widget/modal/group_edit.modal.dart';

import '../model/chat_message.model.dart';
import '../model/chat_room.model.dart';
import '../model/user.model.dart';
import '../service/auth.service.dart';
import '../service/chat_room.service.dart';
import '../service/websocket.service.dart';

class ChatScreen extends StatefulWidget {
  final String token;
  final ChatRoom chatRoom;

  ChatScreen({required this.token, required this.chatRoom});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final AuthService authService = AuthService.instance;
  final ChatMessageService chatMessageService = ChatMessageService.instance;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  late final WebSocketService _webSocketService;
  late final User currentUser;
  bool _isLoading = false;
  int _pageNumber = 0;

  getUser() async {
    currentUser = await authService.getCurrentUser();
  }

  Future<void> getMessages() async {
    _messages.addAll(await chatMessageService.getCurrentUserChatRooms(widget.chatRoom.id!, _pageNumber));
    _pageNumber++;
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService(token: widget.token, toggleMessages: toggleMessages, chatRoomId: widget.chatRoom.id!);
    _webSocketService.connect(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        getUser();
        getMessages();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.name != null ? widget.chatRoom.name! : widget.chatRoom.receiver!.username!),
        centerTitle: true,
        actions: widget.chatRoom.name != null ? [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'leave') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm"),
                      content: Text("Are you sure you want to leave this chat room?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Leave"),
                          onPressed: () {
                            chatRoomService.leaveChat(widget.chatRoom);
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value) {
                    Navigator.pop(context, true);
                  }
                });
              } else if (value == 'edit') {
                showDialog(
                  context: context,
                  builder: (context) => GroupEditModal(
                    groupId: widget.chatRoom.id,
                    groupName: widget.chatRoom.name,
                    groupPhoto: widget.chatRoom.publicChatPhoto,
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Text('Leave chat'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit chat'),
              ),
            ],
          ),
        ] : null,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: null,
              reverse: true,
              itemCount: _messages.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Center(
                    child: _isLoading ? CircularProgressIndicator() : Container(),
                  );
                } else {
                  final messageIndex = _messages.length - index;
                  final message = _messages[messageIndex];
                  return ListTile(
                    title: Text(message.sender!),
                    subtitle: Text(message.content!),
                    trailing: Text(
                      message.timestamp!.toIso8601String(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration.collapsed(hintText: 'Send a message'),
                      onSubmitted: (value) {
                        _sendMessage(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void toggleMessages(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage(String content) {
    if (content.isNotEmpty) {
      final message = ChatMessage(sender: currentUser.username, content: content, chatRoomId: widget.chatRoom.id, timestamp: DateTime.now());
      _webSocketService.sendMessage(message);
      _messageController.clear();
    }
  }
}