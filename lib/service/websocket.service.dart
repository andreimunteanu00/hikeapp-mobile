import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/io.dart';

import '../model/chat_message.model.dart';
import '../util/constants.dart' as constants;

class WebSocketService {
  final String token;
  final Function(ChatMessage) toggleMessages;
  final int chatRoomId;
  late final IOWebSocketChannel channel;
  late final StompClient stompClient;

  WebSocketService({required this.token, required this.toggleMessages, required this.chatRoomId});

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/room/$chatRoomId',
      callback: (StompFrame frame) {
        ChatMessage chatMessage = ChatMessage.fromJson(jsonDecode(frame.body!));
        toggleMessages(chatMessage);
      },
    );
  }

  void connect(String username) async {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: '${constants.webSocketUrl}/chat',
        onWebSocketError: (dynamic error) => throw Exception(error.toString()),
        webSocketConnectHeaders: {
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
          'Authorization': 'Bearer $token'
        },
        stompConnectHeaders: {
        'Connection': 'Upgrade',
        'Upgrade': 'websocket',
        'Authorization': 'Bearer $token'
        },
        onConnect: onConnect
      ),
    );
    stompClient.activate();
  }

  void disconnect() async {
    stompClient.deactivate();
  }

  void sendMessage(ChatMessage chatMessage) {
    stompClient.send(
      destination: '/app/chat',
      body: jsonEncode(chatMessage)
    );
  }
}