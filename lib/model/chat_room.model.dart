import 'package:hikeappmobile/model/chat_message.model.dart';
import 'package:hikeappmobile/model/picture.model.dart';
import 'package:hikeappmobile/model/user.model.dart';

import '../util/enum/chat_type.enum.dart';

class ChatRoom {
  final int? id;
  final String? name;
  final Picture? publicChatPhoto;
  final List<ChatMessage>? chatMessages;
  final User? receiver;
  final List<User?>? userList;
  final ChatType? chatType;

  ChatRoom({
    this.id,
    this.name,
    this.publicChatPhoto,
    this.chatMessages,
    this.receiver,
    this.userList,
    this.chatType
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'publicChatPhoto': publicChatPhoto,
    'chatMessages': chatMessages,
    'userList': userList,
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
        receiver: json['receiver'] == null ? null : User.fromJson(json['receiver'])
    );
  }

}