import 'package:hikeappmobile/model/chat_message.model.dart';
import 'package:hikeappmobile/model/picture.model.dart';
import 'package:hikeappmobile/model/user.model.dart';

import '../util/enum/chat_type.enum.dart';

class ChatRoom {
  final int? id;
  final String? name;
  final Picture? publicChatPhoto;
  final ChatMessage? lastMessage;
  final List<ChatMessage>? chatMessages;
  final User? receiver;
  final List<User?>? userList;
  final List<User?>? adminList;
  final ChatType? chatType;

  ChatRoom({
    this.id,
    this.name,
    this.publicChatPhoto,
    this.lastMessage,
    this.chatMessages,
    this.receiver,
    this.userList,
    this.adminList,
    this.chatType
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'publicChatPhoto': publicChatPhoto,
    'lastMessage': lastMessage,
    'chatMessages': chatMessages,
    'userList': userList,
    'adminList': adminList,
    'chatType': chatType
  };

  factory ChatRoom.fromJsonPrivate(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      receiver: User.fromJson(json['receiver']),
    );
  }

  factory ChatRoom.fromJsonPublic(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      publicChatPhoto: Picture.fromJson(json['publicChatPhoto']),
      userList: (json['userList'] as List<dynamic>)
          .map((e) => e == null ? null : User.fromJson(e))
          .toList(),
      adminList: (json['adminList'] as List<dynamic>)
          .map((e) => e == null ? null : User.fromJson(e))
          .toList()
    );
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        id: json['id'],
        name: json['name'],
        publicChatPhoto: json['publicChatPhoto'] == null ? null : Picture.fromJson(json['publicChatPhoto']),
        userList: json['userList'] == null ? null : (json['userList'] as List<dynamic>)
            .map((e) => e == null ? null : User.fromJson(e))
            .toList(),
        adminList: (json['adminList'] as List<dynamic>)
            .map((e) => e == null ? null : User.fromJson(e))
            .toList(),
        receiver: json['receiver'] == null ? null : User.fromJson(json['receiver']),
        lastMessage: json['lastMessage'] == null ? null : ChatMessage.fromJson(json['lastMessage'])
    );
  }

}