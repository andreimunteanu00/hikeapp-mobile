

class ChatMessage {
  final String? sender;
  final String? content;
  final int? chatRoomId;
  final DateTime? timestamp;

  ChatMessage({
    this.sender,
    this.content,
    this.chatRoomId,
    this.timestamp
  });

  factory ChatMessage.fromJsonSend(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      content: json['content']
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      content: json['content'],
      chatRoomId: json['chatRoom'],
      timestamp: DateTime.parse(json['timestamp'])
    );
  }

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'content': content,
    'chatRoomId': chatRoomId,
    'timeStamp': timestamp
  };
}