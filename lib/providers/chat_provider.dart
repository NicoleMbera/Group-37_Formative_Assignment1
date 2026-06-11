import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _db;
  final Map<String, List<ChatMessage>> _cache = {};

  ChatProvider(this._db);

  List<ChatMessage> messagesFor(String threadId) => _cache[threadId] ?? [];

  Future<void> loadMessages(String threadId) async {
    _cache[threadId] = await _db.getMessages(threadId);
    notifyListeners();
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    final msg = ChatMessage(
      id: '${threadId}_${DateTime.now().millisecondsSinceEpoch}',
      threadId: threadId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      isOwn: true,
    );
    await _db.insertMessage(msg);
    _cache.putIfAbsent(threadId, () => []).add(msg);
    notifyListeners();
  }

  int unreadCount(String threadId) {
    // In a real app this would track read state; mock always returns 0 after loading
    return 0;
  }
}
