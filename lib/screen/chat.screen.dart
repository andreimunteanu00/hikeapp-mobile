import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/chat_message.service.dart';
import 'package:hikeappmobile/widget/modal/group_edit.modal.dart';
import 'package:hikeappmobile/widget/modal/member.modal.dart';

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
  bool _isLoading = true;
  int _pageNumber = 0;
  final _scrollController = ScrollController();
  bool _isScrolledToTop = false;
  bool isUserAdmin = false;

  getUser() async {
    currentUser = await authService.getCurrentUser();
    widget.chatRoom.adminList?.forEach((admin) {
      if (admin?.googleId == currentUser.googleId) {
        isUserAdmin = true;
      }
    });
  }

  Future<void> getMessages() async {
    List<ChatMessage> newMessages = await chatMessageService.getCurrentUserMessageForCurrentRoom(widget.chatRoom.id!, _pageNumber);
    print(newMessages.length);
    if (newMessages.isNotEmpty) {
      if (_messages.isNotEmpty) {
        _pageNumber++;
      } else {
        _isLoading = false;
      }
      _messages.insertAll(0, newMessages);
    }
    setState(() {
      _isScrolledToTop = false;
    });
    if (_pageNumber - 1 == 0) {
      _isLoading = false;
    }
    if (_messages.isEmpty) {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService(token: widget.token, toggleMessages: toggleMessages, chatRoomId: widget.chatRoom.id!);
    _webSocketService.connect(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUser();
      getMessages();
    });
    _scrollController.addListener(() {
      setState(() {
        _isScrolledToTop = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
      });
      if (_isScrolledToTop) {
        getMessages();
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
                          onPressed: () async {
                            await chatRoomService.leaveChat(widget.chatRoom);
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
              } else if (value == 'members') {
                showDialog(
                    context: context,
                    builder: (context) => MemberModal(
                      groupId: widget.chatRoom.id!,
                      members: widget.chatRoom.userList!,
                  )
                ).then((value) => setState(() {}));
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
              if (isUserAdmin)
                const PopupMenuItem(
                value: 'members',
                child: Text('Add member'),
              ),
            ],
          ),
        ] : null,
      ),
      body: !_isLoading ? Column(
        children: <Widget>[
          _isScrolledToTop ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ) : SizedBox.shrink(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
      ) : Center(child: CircularProgressIndicator()),
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