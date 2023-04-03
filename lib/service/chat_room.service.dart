import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/chat_room.model.dart';
import '../model/picture.model.dart';
import '../util/constants.dart' as constants;
import '../util/enum/chat_type.enum.dart';

class ChatRoomService {
  static ChatRoomService? _instance;

  ChatRoomService._();

  static ChatRoomService get instance {
    _instance ??= ChatRoomService._();
    return _instance!;
  }


  Future<ChatRoom> createOrGetChatRoom(List<String> googleIds, String? name, Picture? groupPhoto, ChatType chatType) async {
    var body;
    if (name != null) {
      body = jsonEncode({
        'name': name,
        'googleIds': googleIds,
        'publicChatPhoto': groupPhoto
      });
    } else {
      body = jsonEncode(googleIds);
    }
    final response = await MyHttp.getClient()
      .post(Uri.parse('${constants.localhost}/chat-room/create-or-get/${chatType.name}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body);
    if (response.statusCode != 200) {
      throw new Exception('Failed to load chat room!');
    }
    if (chatType == ChatType.private) {
      return ChatRoom.fromJsonPrivate(json.decode(response.body));
    } else {
      return ChatRoom.fromJsonPublic(json.decode(response.body));
    }
  }

  Future<List<ChatRoom>> getCurrentUserChatRooms() async {
    final response = await MyHttp.getClient()
        .get(Uri.parse('${constants.localhost}/chat-room/current-user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode != 200) {
      throw new Exception('Failed to load chat room!');
    }
    return (jsonDecode(response.body) as List)
        .map((json) => ChatRoom.fromJson(json))
        .toList();
  }

  void leaveChat(ChatRoom chatRoom) async {
    var body = jsonEncode(chatRoom);
    print(body);
    final response = await MyHttp.getClient()
        .delete(Uri.parse('${constants.localhost}/chat-room/leave/current-user/${chatRoom.id}'));
    print(response);
  }

  void editGroup(int groupId, String name, Picture groupPhoto) async {
    var body = jsonEncode({
      'id': groupId,
      'name': name,
      'publicChatPhoto': groupPhoto
    });
    final response = await MyHttp.getClient()
        .put(Uri.parse('${constants.localhost}/chat-room/edit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode != 200) {
      throw new Exception('Failed to edit chat room!');
    }
  }
}
