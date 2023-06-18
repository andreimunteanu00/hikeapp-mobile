import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/chat_message.service.dart';
import 'package:hikeappmobile/widget/modal/group_edit.modal.dart';
import 'package:hikeappmobile/widget/modal/member.modal.dart';
import 'package:intl/intl.dart';

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
  final List<ChatMessage> messages = [];
  final messageController = TextEditingController();
  final AuthService authService = AuthService.instance;
  final ChatMessageService chatMessageService = ChatMessageService.instance;
  final ChatRoomService chatRoomService = ChatRoomService.instance;
  late final WebSocketService webSocketService;
  late final User currentUser;
  bool isLoading = true;
  int pageNumber = 0;
  final scrollController = ScrollController();
  bool isScrolledToTop = false;
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
    List<ChatMessage> newMessages = await chatMessageService.getCurrentUserMessageForCurrentRoom(widget.chatRoom.id!, pageNumber);
    if (newMessages.isNotEmpty) {
      if (messages.isEmpty) {
        isLoading = false;
      }
      messages.insertAll(0, newMessages);
      pageNumber++;
    }
    setState(() {
      isScrolledToTop = false;
    });
    if (pageNumber - 1 == 0) {
      isLoading = false;
    }
    if (messages.isEmpty) {
      isLoading = false;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.isAfter(today)) {
      return 'Today';
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  @override
  void initState() {
    super.initState();
    webSocketService = WebSocketService(token: widget.token, toggleMessages: toggleMessages, chatRoomId: widget.chatRoom.id!);
    webSocketService.connect(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUser();
      getMessages();
    });
    scrollController.addListener(() {
      setState(() {
        isScrolledToTop = scrollController.position.pixels == scrollController.position.maxScrollExtent;
      });
      if (isScrolledToTop) {
        getMessages();
      }
    });
  }

  @override
  void dispose() {
    webSocketService.disconnect();
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
            child: !isLoading ? Column(
              children: <Widget>[
                isScrolledToTop ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ) : const SizedBox.shrink(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: messages.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Center(
                          child: isLoading ? const CircularProgressIndicator() : Container(),
                        );
                      } else {
                        final messageIndex = messages.length - index;
                        final message = messages[messageIndex];
                        final isCurrentUserMessage = message.sender == currentUser.username;
                        final now = DateTime.now();
                        final bool showDate = messageIndex < messages.length - 1 &&
                            (message.timestamp!.day != messages[messageIndex + 1].timestamp!.day ||
                                message.timestamp!.month != messages[messageIndex + 1].timestamp!.month ||
                                message.timestamp!.year != messages[messageIndex + 1].timestamp!.year);
                        bool isLastMessageToday = message.timestamp!.day == now.day &&
                            message.timestamp!.month == now.month &&
                            message.timestamp!.year == now.year &&
                            (messageIndex == 0 ||
                                (messageIndex > 0 &&
                                    (messages[messageIndex - 1].timestamp!.day != now.day ||
                                        messages[messageIndex - 1].timestamp!.month != now.month ||
                                        messages[messageIndex - 1].timestamp!.year != now.year)));
                        return Column(
                          children: [
                            if (showDate || isLastMessageToday) ...[
                              const SizedBox(height: 8.0),
                              Text(
                                _formatDate(message.timestamp!),
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ],
                            Row(
                              mainAxisAlignment: isCurrentUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: isCurrentUserMessage ? const Color.fromRGBO(96, 137, 110, 0.65)
                                        : const Color.fromRGBO(43, 57, 67, 0.65),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      message.sender != currentUser.username ? Text(
                                        message.sender!,
                                        style: const TextStyle(fontSize: 14, color: Colors.white),
                                      ) : const SizedBox.shrink(),
                                      const SizedBox(height: 4),
                                      Text(
                                        message.content!,
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('jm').format(message.timestamp!),
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Send message',
                              hintStyle: TextStyle(color: Colors.white), // Set the hint text color
                            ),
                            style: const TextStyle(color: Colors.white), // Set the input text color
                            onSubmitted: (value) {
                              _sendMessage(value);
                            },
                          )
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white), // Set the icon color to white
                        onPressed: () {
                          _sendMessage(messageController.text);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ) : const Center(child: CircularProgressIndicator()),
          )
        ]
      )
    );
  }

  void toggleMessages(ChatMessage message) {
    setState(() {
      messages.add(message);
    });
  }

  void _sendMessage(String content) {
    if (content.isNotEmpty) {
      final message = ChatMessage(sender: currentUser.username, content: content, chatRoomId: widget.chatRoom.id, timestamp: DateTime.now());
      webSocketService.sendMessage(message);
      messageController.clear();
    }
  }
}