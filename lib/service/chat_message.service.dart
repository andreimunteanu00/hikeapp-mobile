import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/chat_message.model.dart';
import '../util/constants.dart' as constants;

class ChatMessageService {
  static ChatMessageService? _instance;

  ChatMessageService._();

  static ChatMessageService get instance {
    _instance ??= ChatMessageService._();
    return _instance!;
  }

  Future<List<ChatMessage>> getCurrentUserChatRooms(int roomId, int page) async {
    final response = await MyHttp.getClient()
        .get(Uri.parse('${constants.localhost}/chat-message/private/$roomId?page=$page'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode != 200) {
      throw new Exception('Failed to load chat messages!');
    }
    var jsonResponse = jsonDecode(response.body);
    return (jsonResponse['content'] as List)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

}
