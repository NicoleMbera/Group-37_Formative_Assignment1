class ChatMessage {
  final String id;
  final String threadId; // community id or DM thread id
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isOwn;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isOwn,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isOwn': isOwn ? 1 : 0,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        threadId: map['threadId'] as String,
        senderId: map['senderId'] as String,
        senderName: map['senderName'] as String,
        content: map['content'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        isOwn: (map['isOwn'] as int) == 1,
      );
}
